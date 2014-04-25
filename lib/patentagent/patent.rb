# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3

require "patentagent/patent_number"
require "forwardable"

module PatentAgent    
  class Patent
    DEFAULT_OPTIONS = {
      authority: :pto,
      debug:     false,
      logging:   true  
    }
    attr_reader :pat_num, :patent
    
    extend Forwardable

    def_delegators :pat_num, :number, :cc, :kind
    
    #
    # allows calling fetch on directly on Patent class
    # initializes and fetches
    # 
    # @return [Patent] A new instance of PatentAgent::Patent
    #
    def self.fetch(pnum, options = {})
      new(pnum, options).fetch
    end

    def self.config(pnum, opts = {})
      yield self if block_given?
    end
    
    def initialize(pnum, options = {})
      set_options options
      @pat_num = PatentNumber.new(pnum)

      return unless valid?
     
      @patent = case @options[:authority]
      when :pto
        PTO::PTOPatent.new(@pat_num)
      # when :epo
      #   OPS::Patent.new(@patent_num)
      else
        PTO::PTOPatent.new(@pat_num)
      end
    end

    def fetch
      @patent.fetch
    end

    def authority
      @options[:authority]
    end

    def debug
      @options[:debug]
    end


    def valid?
      @pat_num && @pat_num.valid?
    end

    def fetched?
      number && inventors && priority_date
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
        @options ||= DEFAULT_OPTIONS
        @options.merge!(opts)
        PatentAgent.debug = @options[:debug]
      end
  end
end
