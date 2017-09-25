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
        "email" => "hd@diaoma.com",
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
        expect(mindmatch.create_match(talents: talents, position: position)).to eql('6906ec3d-024d-43c6-a1cf-9b102eec4fb1')
      end
    end

    it 'returns a score for a match id' do
      VCR.use_cassette("query_match") do
        expect(mindmatch.query_match(id: '6906ec3d-024d-43c6-a1cf-9b102eec4fb1')['results'].first['score']).to eql(0.1436655436)
      end
    end
  end
end
