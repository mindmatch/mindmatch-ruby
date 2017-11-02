require 'faraday'
require 'json'

module MindMatch
  class ArgumentError < StandardError; end
  class Unauthorized < StandardError; end
  class UnexpectedError < StandardError; end
  class RequestEntityTooLarge < StandardError; end

  class Client
    DEFAULT_ENDPOINT = 'https://api.mindmatch.ai'.freeze
    PATH = '/graphql'.freeze

    def initialize(token:, endpoint: DEFAULT_ENDPOINT)
      @token = token
      uri = URI(endpoint)
      uri.path = PATH
      @conn = Faraday.new(url: uri.to_s, headers: headers)
    end

    def create_match(talent: nil, talents: [], position: nil, positions: [], companies: [])
      talents << talent
      talents = talents.compact
      positions << position
      companies = (companies + positions).compact
      raise ArgumentError, "missing keyword: talents" if talents.empty?
      raise ArgumentError, "missing keyword: companies" if companies.empty?
      create_matches(talents: talents, companies: companies)
    end

    def query_match(id:, query: nil)
      unless query.is_a?(QueryBuilder)
        query = (@query_match_query ||= QueryBuilder.new
          .with_results(%w(score personId positionId companyId))
          .with_people(%w(id refId))
          .with_positions(%w(id refId))
          .build)
      end

      query_match_score = <<-GRAPHQL
        query ($id: String!) {
          getMatch(id: $id) {
            id
            status
            #{query.to_s}
          }
        }
      GRAPHQL

      raw_response = conn.get do |req|
        req.body = JSON.generate(query: query_match_score, variables: {id: id}.to_json)
      end
      handle_error(raw_response)
      response = JSON.parse(raw_response.body)
      match = response.dig('data', 'getMatch')
      if match&.has_key?('data') # FIX: remove data namespace in mindmatch api
        match = match.merge(match['data'] || query.to_h)
        match.delete('data')
      end
      match || query.to_h
    end

    private
    attr_reader :conn, :token

    def create_matches(talents:, companies:)
      create_match_mutation = <<-GRAPHQL
        mutation ($companies: [CompanyInput], $people: [PersonInput]) {
          createMatch(
            input: {
              companies: $companies,
              people: $people
            }
          ) {
            id
          }
        }
      GRAPHQL

      raw_response = conn.post do |req|
        req.body = JSON.generate(
          query: create_match_mutation,
          variables: {
            companies: companies.map(&method(:companiesql)),
            people: talents.map(&method(:talentql))
          }.to_json
        )
      end
      handle_error(raw_response)
      response = JSON.parse(raw_response.body)
      match = response.dig('data', 'createMatch')
      if match&.has_key?('data') # FIX: remove data namespece in mindmatch api
        match = match.merge(match['data'] || {'results'=>[], 'people'=>[], 'positions'=>[]})
        match.delete('data')
      end
      match && match['id']
    end

    def positionql(position)
      position = stringify(position)
      {
        refId: position['id'],
        name: position['name'],
        description: position['description'],
        technologies: position['technologies'] || []
      }
    end

    def companiesql(company)
      company = stringify(company)
      {
        name: company['name'],
        location: [company['location']].flatten,
        url: company['url'],
        profileUrls: company['profileUrls'] || [],
        positions: company.fetch('positions', []).map(&method(:positionql))
      }
    end

    def talentql(tal)
      tal = stringify(tal)
      {
        refId: tal['id'],
        name: tal['name'],
        email: tal['email'],
        profileUrls: tal['profileUrls'] || [],
        resumeUrl: tal['resumeUrl'],
        skills: tal['skills'] || []
      }
    end

    def headers
      {
        "Authorization": "Bearer #{token}",
        "Accept": "application/json",
        "Content-Type": "application/json"
      }
    end

    def handle_error(raw_response)
      return if raw_response.status.to_s =~ /2\d\d/ and error_free?(raw_response.body)

      case raw_response.status
        when 400 then raise(ArgumentError, raw_response.body)
        when 401 then raise(Unauthorized, raw_response.body)
        when 413 then raise(RequestEntityTooLarge, raw_response.body)
        else raise(UnexpectedError, raw_response.status, raw_response.body)
      end
    end

    def error_free?(body)
      !JSON.parse(body).has_key?('errors')
    rescue StandardError
      return false
    end

    def stringify(hash)
      JSON.parse(JSON.generate(hash))
    end
  end
end
