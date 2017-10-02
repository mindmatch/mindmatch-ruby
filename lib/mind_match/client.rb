require 'faraday'
require 'json'

module MindMatch
  class ArgumentError < StandardError; end
  class Unauthorized < StandardError; end
  class UnexpectedError < StandardError; end

  class Client

    DEFAULT_ENDPOINT = 'https://api.mindmatch.ai'
    PATH = '/graphql'

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

    def query_match(id:)
      query_match_score = <<-GRAPHQL
        query getMatch {
          match: getMatch(id: "#{id}") {
            id
            status
            data {
              results {
                score
                personId
                positionId
              }
              people {
                id
                refId
              }
              positions {
                id
                refId
              }
            }
          }
        }
      GRAPHQL

      raw_response = conn.get do |req|
        req.body = JSON.generate(query: query_match_score)
      end
      handle_error(raw_response)
      response = JSON.parse(raw_response.body)
      match = response.dig('data', 'match')
      if match&.has_key?('data') # FIX: remove data namespece in mindmatch api
        match = match.merge(match['data'] || {'results'=>[], 'people'=>[], 'positions'=>[]})
        match.delete('data')
      end
      match
    end

    private
    attr_reader :conn, :token

    def create_matches(talents:, companies:)
      create_match_mutation = <<-GRAPHQL
        mutation createMatch {
          match: createMatch(
            input: {
              data: {
                companies: [#{companies.map(&method(:companiesql)).join(',')}],
                people: [#{talents.map(&method(:talentql)).join(',')}]
              }
            }
          ) {
            id
          }
        }
      GRAPHQL

      raw_response = conn.post do |req|
        req.body = JSON.generate(query: create_match_mutation)
      end
      handle_error(raw_response)
      response = JSON.parse(raw_response.body)
      match = response.dig('data', 'match')
      if match&.has_key?('data') # FIX: remove data namespece in mindmatch api
        match = match.merge(match['data'] || {'results'=>[], 'people'=>[], 'positions'=>[]})
        match.delete('data')
      end
      match['id']
    end

    def positionql(position)
      position = stringify_keys(position)
      <<-EOS.split.join(" ")
        {
          refId: "#{position['id']}",
          name: "#{position['name']}",
          description: "#{position['description']}"
        }
      EOS
    end

    def companiesql(company)
      company = stringify_keys(company)
      if company.has_key?("positions")
        <<-EOS.split.join(" ")
          {
            name: "#{company['name']}",
            location: #{[company['location']].flatten},
            url: "#{company['url']}",
            profileUrls: #{company['profileUrls'] || []},
            positions: [#{company['positions'].map(&method(:positionql)).join(', ')}]
          }
        EOS
      else
        warn "[DEPRECATION] providing postition without company information is deprecated."
        <<-EOS.split.join(" ")
          {
            name: "company",
            location: ["location"],
            url: "http://example.com",
            profileUrls: ["https://github.com/honeypotio", "https://linkedin.com/company/honeypot"],
            positions: [#{positionql(company)}]
          }
        EOS
      end
    end

    def talentql(tal)
      tal = stringify_keys(tal)
      <<-EOS.split.join(" ")
        {
          refId: "#{tal['id']}",
          name: "#{tal['name']}",
          email: "#{tal['email']}",
          profileUrls: #{tal['profileUrls'] || []},
          resumeUrl: "#{tal['resumeUrl']}",
          skills: #{tal['skills'] || []}
        }
      EOS
    end

    def headers
      {
        "Authorization": "Bearer #{token}",
        "Accept": "application/json",
        "Content-Type": "application/json"
      }
    end

    def handle_error(raw_response)
      return if raw_response.status.to_s =~ /2\d\d/

      case raw_response.status
        when 400 then raise(ArgumentError, raw_response.body)
        when 401 then raise(Unauthorized, raw_response.body)
        else raise(UnexpectedError, raw_response.status, raw_response.body)
      end
    end

    def stringify_keys(hash)
      JSON.parse(JSON.generate(hash))
    end
  end
end
