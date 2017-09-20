require 'faraday'
require 'json'

module MindMatch
  class Client

    DEFAULT_ENDPOINT = 'https://api.mindmatch.ai/graphql'

    def initialize(token:, endpoint: DEFAULT_ENDPOINT)
      @conn = Faraday.new(:url => endpoint, :headers => {
        "Authorization": "Bearer #{token}",
        "Accept": "application/json",
        "Content-Type": "application/json"
      })
    end

    def create_match(talents:, position:)
      create_match_mutation = <<-GRAPHQL
        mutation createMatch {
          match: createMatch(
            input: {
              data: {
                companies: [{
                  name: "company",
                  location: ["location"],
                  url: "http://example.com",
                  profileUrls: ["https://github.com/honeypotio", "https://linkedin.com/company/honeypot"],
                  positions: [#{positionql(position)}]
                }],
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
      response = JSON.parse(raw_response.body)
      response['data']['match']['id']
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
              }
            }
          }
        }
      GRAPHQL

      raw_response = conn.get do |req|
        req.body = JSON.generate(query: query_match_score)
      end
      response = JSON.parse(raw_response.body)
      response['data']['match']['data']['results']
    end

    private
    attr_reader :conn

    def positionql(position)
      <<-EOS.split.join(" ")
        {
          refId: "#{position['id']}",
          name: "#{position['name']}",
          description: "#{position['description']}"
        }
      EOS
    end

    def talentql(tal)
      <<-EOS.split.join(" ")
        {
          refId: "#{tal['id']}",
          name: "#{tal['name']}",
          email: "#{tal['email']}",
          profileUrls: #{tal['profileUrls']},
          resumeUrl: "#{tal['resumeUrl']}",
          skills: #{tal['skills']}
        }
      EOS
    end
  end
end
