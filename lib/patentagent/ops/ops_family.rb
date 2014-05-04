require 'nokogiri'

module PatentAgent
  module OPS  
    class OpsFamily
      include PatentAgent
      include Enumerable
      
      attr_accessor  :patent, :members, :family_id
      
      def initialize(pnum, xml)   

        @patent = PatentNumber(pnum)
        
        # returns a Nokogiri NodeSet
        # need to get the family id from the first one......
        #
        nodes      = Nokogiri::XML(xml).css("ops|family-member")
        @members   = nodes.map {|node| OPS::Fields.new(node) }  
      end

      def first
        members[0]
      end

      def [](index); members[index]; end
      
      # define #each so we get all the enumberable methods.... 
      def each
        members.each {|x| yield x}
      end

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