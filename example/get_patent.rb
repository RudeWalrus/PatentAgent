$: << File.dirname(__FILE__) + '../lib'

require 'patentagent.rb'

patent = PatentAgent::USPTO::Patent.new("US8031115")