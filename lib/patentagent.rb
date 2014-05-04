$: << File.dirname(__FILE__) + '../patentagent'
$: << File.dirname(__FILE__) + '../patentagent/pto'

require 'patentagent/patent'
require 'patentagent/logging'
require 'patentagent/patent_number'
require 'patentagent/client'
require 'patentagent/hydra'
require 'patentagent/forward_citations'
require 'patentagent/fc_patents'


require 'patentagent/ops/ops_patent'
require 'patentagent/ops/fields'
require 'patentagent/ops/ops_family'

require 'patentagent/pto/claims'
require 'patentagent/pto/pto_patent'
require 'patentagent/pto/fields'

module PatentAgent

  class << self
    attr_accessor :debug, :ops_id, :ops_secret
  end

  def self.debug=(val)
    @debug = val
    if val == TRUE
      self.logger.level = Logger::DEBUG 
    else
      self.logger.level = Logger::INFO 
    end
  end

  # validates a list of patent numbers
  #
  # @returns - an array of valid numbers if array passed in
  #          - or a string if a string passed in
  #
  def self.validate_patent_numbers(*nums)
    valid = [*nums].flatten.find_all { |pnum| PatentNumber.valid_patent_number(pnum) }
    valid.size == 1 ? valid[0] : valid
  end
  
  def self.configure
    yield Config
  end

  extend PatentAgent::Logging

end