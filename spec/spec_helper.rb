require 'rspec'
require 'patentagent'
require 'vcr'
require 'webmock/rspec'


if $LOADED_FEATURES.grep(/spec\/spec_helper\.rb/).any?
  begin
    raise "foo"
  rescue => e
    puts <<-MSG
  ===================================================
  It looks like spec_helper.rb has been loaded
  multiple times. Normalize the require to:

    require "spec/spec_helper"

  Things like File.join and File.expand_path will
  cause it to be loaded multiple times.

  Loaded this time from:

    #{e.backtrace.join("\n    ")}
  ===================================================
    MSG
  end
end


RSpec.configure do |config|
  config.mock_framework = :rspec
end

VCR.configure do |c|
  c.cassette_library_dir = File.dirname(__FILE__) + '/fixtures/cassettes'
  c.hook_into :webmock
  c.default_cassette_options = {record: :new_episodes}
  c.configure_rspec_metadata!
end
