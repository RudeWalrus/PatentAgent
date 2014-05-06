require 'nokogiri'
require 'json'

module PatentAgent
  module OPS  
    class OpsFamily
      include PatentAgent::Util
      include Enumerable
      
      attr_reader  :patent, :members, :family_id, :names
      
      def initialize(pnum, xml)   

        @patent = PatentNumber(pnum)
        parse(xml) 
      end

      def parse(xml)
        # returns a Nokogiri NodeSet
        # need to get the family id from the first one......
        #
        nodes      = Nokogiri::XML(xml).css("ops|family-member")
        @members   = nodes.map {|node| OPS::Fields.new(node) }  
        @names     = @members.map(&:number)
      end

      def first
        @first ||= members.find {|x| x.number.match @patent.number}
      end

      def family_id
        first.family_id
      end

      def [](index); members[index]; end
      
      # define #each so we get all the enumberable methods.... 
      def each
        members.each {|x| yield x}
      end

      def to_h
        hash   = {names: @names, family_id: family_id}
        family = @members.map(&:to_h)
        hash.merge(family: family)
      end
      
      def family_issued
        @members.select{|field| field.number if field.issued?}.map{|field| field.number}.sort
      end

      alias :to_hash :to_h
      protected

      #
      # delegate calls for the fields to the OPSFields object
      # the primary patent is the first one in the array
      #
      def method_missing(method, *args)
        return members[0].send(method) if members[0].respond_to?(method)
        super
      end

      def respond_to_missing?(method, include_private = false)
        members[0].respond_to?(method) || super
      end
    end
  end
end