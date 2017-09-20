require 'spec_helper'

RSpec.describe MindMatch do
  let(:token) { 'XvtLRvsxNr4tOpmVpVFNWkJrxyc24hkjZA' }
  let(:endpoint) { 'https://staging-mindmatch-api.herokuapp.com/graphql' }
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
      VCR.use_cassette("mind_match/single_talent") do
        expect(mindmatch.create_match(talents: talents, position: position)).to eql('14288875-bf0f-462a-90b5-eb83a209cf02')
      end
    end

    it 'returns a score for a match id' do
      VCR.use_cassette("mind_match/query_match") do
        expect(mindmatch.query_match(id: '14288875-bf0f-462a-90b5-eb83a209cf02').first['score']).to eql(0.5)
      end
    end
  end
end
