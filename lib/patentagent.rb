require 'nokogiri'
require 'rest_client'
require 'set'
require 'logger'

$: << File.dirname(__FILE__) + '../patentagent'

require 'patentagent/patent'
require 'patentagent/util'
require 'patentagent/logging'
require 'patentagent/claims'
require 'patentagent/patent_num'

# require 'patentagent/ops/ops_utility'
# require 'patentagent/ops/ops_reader'
# require 'patentagent/ops/ops_patent'


require 'patentagent/us/us_client'
require 'patentagent/us/us_patent'


module PatentAgent
  class << self
    def version
        version_path = File.dirname(__FILE__) + "/../VERSION"
        return File.read(version_path).chomp if File.file?(version_path)
        "0.0.1"
    end
  end
end