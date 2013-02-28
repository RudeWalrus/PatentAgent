require 'nokogiri'
require 'rest_client'
require 'set'
require 'logger'

$: << File.dirname(__FILE__) + '../patentagent'

require 'patentagent/util'
require 'patentagent/claims'
require 'patentagent/logging'
require 'patentagent/ops/ops_utility'
require 'patentagent/ops/ops_reader'
require 'patentagent/ops/ops_patent'


require 'patentagent/pto/pto_reader'
require 'patentagent/pto/pto_patent'


module PatentAgent
  class << self
    def version
        version_path = File.dirname(__FILE__) + "/../VERSION"
        return File.read(version_path).chomp if File.file?(version_path)
        "0.0.1"
    end
    
    def symbol_to_string(symbol)
      return symbol if symbol.is_a?(String)
      str = Array(symbol.to_s.split("_"))
      str.map(&:capitalize).join(" ")
    end 
  
    def to_symbol(name)
      symbol = name.to_s.downcase
      symbol.gsub(" ", "_")
    end
  end 
end