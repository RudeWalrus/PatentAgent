require 'rubygems'
require 'rspec'
require 'patentagent'

#$: << File.join(File.dirname(__FILE__), *%w[.. lib])


#

RSpec.configure do |config|
  config.mock_framework = :rspec
end
