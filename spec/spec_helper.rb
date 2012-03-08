require 'rubygems'
require 'rspec'

$: << File.join(File.dirname(__FILE__), *%w[.. lib])

require 'patentagent'

#

RSpec.configure do |config|
  config.mock_framework = :rspec
end