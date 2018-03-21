require 'spec_helper'

RSpec.describe MindMatch::QueryBuilder do
  it 'builds single level queries' do
    expect(described_class.new.with_people(%w(id refId)).to_s).to eq(<<-EOS)
people {
id
refId}
    EOS
  end

  it 'builds multi level queries level queries' do
    expect(described_class.new.with_results(['score', 'positionKeywords' => ['name']]).to_s).to eq(<<-EOS)
results {
score
positionKeywords {
name}}
    EOS
  end
end
