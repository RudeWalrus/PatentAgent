# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3

require "patentagent/patent_number"
require "forwardable"

module PatentAgent    
  class Patent
    
    attr_reader :pnum
    include PatentAgent
    extend Forwardable
    def_delegators :pnum, :number, :cc, :kind
    
    
    def initialize(pnum, options = {})
      set_options options
      @pnum = PatentNumber(pnum)

      @ops = OPS::OpsPatent.new(pnum)
      @pto = PTO::PTOPatent.new(pnum)
      
      # @family = @ops.family
      # @patent = @family[0] 
      
    end
      #
      # map the Claims structs to hashes
      #
    def claims
      @claims ||= begin
        @claims = {}
        @pto.claims.each {|k,v| @claims[k] = v.to_hash }
        @claims
      end
    end

    def patent
      @patent ||= (family[0] || {})
    end

    def family
      @family ||= (@ops.family || [])
    end

    private
      #
      # delegate calls for the fields to the PatentFields object
      #
      def method_missing(method, *args)
        return @patent.send(method) if @patent.respond_to?(method)
        super
      end

      def respond_to_missing?(method, include_private = false)
        @patent.respond_to?(method) || super
      end

    def set_options(opts)
        #@options.merge!(opts)
        @options = {}
        PatentAgent.debug = @options.fetch(:debug) {false}
      end
  end
end
