require 'spec_helper'

RSpec.describe MindMatch do
  let(:token) { ENV.fetch('MINDMATCH_TOKEN', 'yourtokencomeshere') }
  let(:endpoint) { 'https://staging-api.mindmatch.ai' }
  subject(:mindmatch) { described_class.new(token: token, endpoint: endpoint) }

  it "has a version number" do
    expect(MindMatch::VERSION).not_to be nil
  end

  describe '#match' do
    let(:talents) { [{
        "id" => 2,
        "name" => "Hugo Duksis",
        :email => "hd@diaoma.com",
        "profileUrls" => [
          "https://linkedin.com/in/duksis",
          "https://github.com/duksis",
          "https://twitter.com/duksis"
        ],
        "skills" => [
          "Javascript",
          "ruby",
          "elixir",
          "git"
        ]
      }]
    }

    let(:position) { {
        "id" => 324,
        "name" => "Elixir Frontend Developer",
        "description" => "4+ years experience with Ruby on Rails and API's, and elixir JS"
      }
    }

    it 'returns an id for a list of talents & position' do
      VCR.use_cassette("create_match") do
        expect(mindmatch.create_match(talents: talents, position: position)).to eql('1d7964c9-7219-4d77-aee3-ece7919f9af5')
      end
    end

    let(:match) { mindmatch.query_match(id: '6ecc0537-63ea-4a39-9d4c-e2c2b054b70d') }

    it 'returns the status for a match id' do
      VCR.use_cassette("query_match") do
        expect(match["id"]).to eql('53b03dc2-07dd-40a2-91fe-7bff24c86574')
        expect(match["status"]).to eql('fulfilled')
      end
    end

    let(:match_result) { match.dig("results")[0] }

    it 'returns the score and the ids for a match id' do
      VCR.use_cassette("query_match") do
        expect(match_result["score"]).to eql(0.1436655436)
        expect(match_result["personId"]).to eql('7dedffb3-c41e-4046-aa3d-73979d7ec1c2')
        expect(match_result["positionId"]).to eql('6214ab8d26e3f79571d922ca269d5743')
      end
    end

    let(:match_people) { match.dig("people")[0] }

    it 'returns the persoun ids object for a match id' do
      VCR.use_cassette("query_match") do
        expect(match_people["id"]).to eql('7dedffb3-c41e-4046-aa3d-73979d7ec1c2')
      end
    end

    let(:match_positions) { match.dig("positions")[0] }

    it 'returns the position ids object for a match id' do
      VCR.use_cassette("query_match") do
        expect(match_positions["id"]).to eql('6214ab8d26e3f79571d922ca269d5743')
      end
    end

    context 'position with company data' do
      let(:position) { {
        "name" => "MindMatch GmbH",
        "location" => "Berlin, Germany",
        "url" => "https://mindmatch.ai",
        "profileUrls" => ["https://github.com/mindmatch"],
        "positions" => [{
            "id" => 324,
            "name" => "Elixir Frontend Developer",
            "description" => "4+ years experience with Ruby on Rails and API's, and elixir JS"
          }]
        }
      }

      it 'returns an id for a list of talents & position' do
        VCR.use_cassette("create_match_with_company_data") do
          expect(mindmatch.create_match(talents: talents, position: position)).to eql('5ab36ee2-2121-49db-bf3d-8623fa4e0a09')
        end
      end
    end

    context 'invalid data' do
      let(:talents) { [{
          "id" => 2,
          "name" => "Hugo Duksis",
          "skills" => [
            "Javascript",
            "ruby",
            "elixir",
            "git"
          ]
        }]
      }
      let(:position) { {
          "id" => 324
        }
      }

      it 'raise exception with explanation' do
        VCR.use_cassette("create_match_invalid_data") do
          expect { mindmatch.create_match(talents: talents, position: position) }.to raise_error(MindMatch::ArgumentError)
        end
      end
    end
  end
end
