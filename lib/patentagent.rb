require 'nokogiri'
require 'rest_client'
require 'set'
require 'logger'

$: << File.dirname(__FILE__) + '../patentagent'
$: << File.dirname(__FILE__) + '../patentagent/us'

require 'patentagent/patent'
require 'patentagent/util'
require 'patentagent/logging'
require 'patentagent/patent_number'
require 'patentagent/reader'
require 'patentagent/claims'

require 'patentagent/ops/ops_utility'
require 'patentagent/ops/ops_reader'
require 'patentagent/ops/ops_patent'

require 'patentagent/us/urls'
require 'patentagent/us/uspto_patent'
require 'patentagent/us/fields'
require 'patentagent/us/forward_citations'

module PatentAgent

  class << self
    attr_accessor :debug

    #
    # validates a list of patent numbers
    #
    # @returns - an array of valid numbers if array passed in
    #          - or a string if a string passed in
    #
    def validate_patent_numbers(*nums)
      valid = [*nums].flatten.find_all { |pnum| PatentNumber.valid_patent_number?(pnum) }
      valid.size == 1 ? valid[0] : valid
    end
  end
end