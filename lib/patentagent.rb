$: << File.dirname(__FILE__) + '../patentagent'
$: << File.dirname(__FILE__) + '../patentagent/pto'

require 'patentagent/patent'
require 'patentagent/logging'
require 'patentagent/patent_number'
require 'patentagent/dispatcher'
require 'patentagent/client'
require 'patentagent/patent_hydra'



require 'patentagent/ops/ops_reader'
require 'patentagent/ops/ops_patent'
require 'patentagent/ops/ops_fields'

require 'patentagent/pto/pto_reader'
require 'patentagent/pto/claims'
require 'patentagent/pto/pto_patent'
require 'patentagent/pto/fields'
require 'patentagent/pto/forward_citations'

module PatentAgent

  class << self
    attr_accessor :debug, :ops_id, :ops_secret

    #
    # validates a list of patent numbers
    #
    # @returns - an array of valid numbers if array passed in
    #          - or a string if a string passed in
    #
    def validate_patent_numbers(*nums)
      valid = [*nums].flatten.find_all { |pnum| PatentNumber.valid_patent_number(pnum) }
      valid.size == 1 ? valid[0] : valid
    end
  end
  
  def self.configure
    yield Config
  end
end