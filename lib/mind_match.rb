require 'mind_match/version'
require 'mind_match/query_builder'
require 'mind_match/client'
require 'forwardable'

module MindMatch
  extend SingleForwardable

  def_delegators ::MindMatch::Client, :new
end
