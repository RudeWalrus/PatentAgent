# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3

require "patentagent/patent_num"
require 'forwardable'

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
    def_delegators :patent, :fetch, :title, :abstract, :assignees, :app_number
    def_delegators :patent, :inventors, :priority_date, :claims
    
    def initialize(pnum, options = {})
      set_options options
      @pat_num = PatentNum.new(pnum)

      return unless valid?
      @patent = case @options[:authority]
      when :pto
        USPTO::Patent.new(@pat_num)
      # when :epo
      #   OPS::Patent.new(@patent_num)
      else
        USPTO::Patent.new(@pat_num)
      end
    end

    def authority
      @options[:authority]
    end

    def debug
      @options[:debug]
    end

    def self.config(pnum, opts = {})
      yield self if block_given?
    end

    def valid?
      @pat_num && @pat_num.valid?
    end

    def fetched?
      number && inventors && priority_date
    end

    private

    def set_options(opts)
        @options ||= DEFAULT_OPTIONS
        @options.merge!(opts)
        PatentAgent.debug = @options[:debug]
      end
  end
end
