module PatentAgent

  # The PatentAgent configuration used to set global
  # options.
  # @example Set the configuration options within a block.
  #   PatentAgent.configure do |config|
  #     config.debug = true
  #   end
  #
  # @example Set the configuration directly.
  #   PatentAgent::Config.logger = $STDOUT
  module Config
    extend self

    attr_accessor :debug

    # Used for OAuth authentication for the OPS Service
    # if Authenticated access is desired, set these to 
    # appropriate id and secret keys. 
    attr_accessor :ops_id, :ops_secret

    # The default logger for all of PatentAgent
    attr_accessor :logger
  end
end