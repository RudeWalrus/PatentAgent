require 'rspec'
require 'patentagent'
require 'vcr'
require 'webmock/rspec'

$: << File.dirname(__FILE__) + '../patentagent'
$: << File.dirname(__FILE__) + '../patentagent/pto'

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.before :each do
    Typhoeus::Expectation.clear
  end
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

VCR.configure do |c|
  c.cassette_library_dir = File.dirname(__FILE__) + '/fixtures/cassettes'
  c.hook_into :webmock
  c.default_cassette_options = {record: :new_episodes}
  c.allow_http_connections_when_no_cassette = true
  c.configure_rspec_metadata!
end
