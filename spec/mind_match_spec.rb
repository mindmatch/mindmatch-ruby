require 'spec_helper'

RSpec.describe MindMatch do
  let(:token) { ENV.fetch('MINDMATCH_TOKEN', 'yourtokencomeshere') }
  let(:endpoint) { 'https://staging-api.mindmatch.ai' }
  subject(:mindmatch) { described_class.new(token: token, endpoint: endpoint) }

  it "has a version number" do
    expect(MindMatch::VERSION).not_to be nil
  end

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

  let(:description) { "4+ years experience with Ruby on Rails and API's, and elixir JS" }
  let(:position) { {
    "name" => "MindMatch GmbH",
    "location" => "Berlin, Germany",
    "url" => "https://mindmatch.ai",
    "profileUrls" => ["https://github.com/mindmatch"],
    "positions" => [{
        "id" => 324,
        "name" => "Elixir Frontend Developer",
        "technologies" => ["Ruby", "Ruby on Rails", "Elixir", "API"],
        "description" => description
      }]
    }
  }

  describe '#create_match' do
    it 'returns an id for a list of talents & position' do
      VCR.use_cassette("create_match") do
        expect(mindmatch.create_match(talents: talents, position: position)).to eql('b55c8aba-8a64-4a2d-bee1-ecece8add36e')
      end
    end

    context "Double quetes in description" do
      let(:description) { "4+ years experience with \"Ruby on Rails\" and API's, and elixir JS" }

      it 'returns an id for a list of talents & position' do
        VCR.use_cassette("create_match_with_quotes_in_data") do
          expect(mindmatch.create_match(talents: talents, position: position)).to eql('7428f7c6-05d2-4adb-a431-f6b629e2b685')
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
          # TODO: should be ArgumentError https://github.com/mindmatch/mindmatch/issues/247
          expect { mindmatch.create_match(talents: talents, position: position) }.to raise_error(MindMatch::UnexpectedError)
        end
      end
    end

  end

  describe '#query_match' do
    let(:match) { mindmatch.query_match(id: 'b55c8aba-8a64-4a2d-bee1-ecece8add36e') }

    it 'returns the status for a match id' do
      VCR.use_cassette("query_match") do
        expect(match["id"]).to eql('b55c8aba-8a64-4a2d-bee1-ecece8add36e')
        expect(match["status"]).to eql('fulfilled')
      end
    end

    let(:match_result) { match.dig("results")[0] }

    it 'returns the score and the ids for a match id' do
      VCR.use_cassette("query_match") do
        expect(match_result["score"]).to eql(0.22283216230156327)
        expect(match_result["personId"]).to eql('7dedffb3-c41e-4046-aa3d-73979d7ec1c2')
        expect(match_result["positionId"]).to eql('9084a00003008113492111b0cdd14a7e')
        expect(match_result["companyId"]).to eql('32252ede8c1e5f24250f67eee4c31d11')
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
        expect(match_positions["id"]).to eql('9084a00003008113492111b0cdd14a7e')
      end
    end

    context 'response data is nil' do
      it 'returns keys as empty vals' do
        VCR.use_cassette("query_returnts_empty_data", match_requests_on: [:query]) do
          expect(mindmatch.query_match(id: 'addbff78-4631-4c05-86e5-8ddee2162a5e')['results']).to eq([])
        end
      end
    end
  end

  describe '#add_feedback' do
    it 'it returns a feedback with id' do
      VCR.use_cassette("add_feedback") do
        expect(mindmatch.add_feedback(
          request_id: '14bc4007-725b-43c8-8cc8-26f49c6e6962',
          person_id: '7dedffb3-c41e-4046-aa3d-73979d7ec1c2',
          position_id: '9084a00003008113492111b0cdd14a7e',
          company_id: '32252ede8c1e5f24250f67eee4c31d11',
          value: false,
          comment: 'Lacking FE experience - otherwise quiet ok'
        )['id']).to eq('baf31287-8c0c-4414-b456-2f11526cc816')
      end
    end
  end
end
