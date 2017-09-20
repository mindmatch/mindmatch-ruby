require "bundler/setup"
require "mindmatch"
require 'webmock/rspec'
require 'vcr'

WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |config|
  config.hook_into :webmock
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.filter_sensitive_data("Bearer [^\"]+", "Bearer yourtokencomeshere")
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
