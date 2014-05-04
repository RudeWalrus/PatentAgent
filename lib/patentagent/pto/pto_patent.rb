# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3


module PatentAgent
  module PTO
    class PtoPatent
      include PatentAgent
      
      attr_reader :patent, :fields, :claims
      alias :name :patent

      extend Forwardable
      def_delegators :patent, :number, :kind, :cc
      #alias to_h to_hash

      
      def initialize(pnum, html)
        @patent     = PatentNumber(pnum)
        @fields     = Fields.new(html)
        @claims     = Claims.new(html)
        PatentAgent.dlog "Processed: #{@patent.to_s}" 
      end

      def to_h; @fields.to_h; end

      private
      #
      # delegate calls for the fields to the PatentFields object
      #
      def method_missing(method, *args)
        return @fields.send(method) if @fields.respond_to?(method)
        super
      end

      def respond_to_missing?(method, include_private = false)
        @fields.respond_to?(method) || super
      end
    end
  end   
end