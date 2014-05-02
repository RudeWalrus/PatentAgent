# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3

require "patentagent/patent_number"
require 'typhoeus'
require "forwardable"

module PatentAgent  
  class Patent
    include PatentAgent
    extend Forwardable
    
    attr_accessor :hydra, :pnum
    attr_accessor :patent, :results, :family, :pto, :fc, :claims

    def_delegators :pnum, :number, :cc, :kind
    #
    # get the patent info for patent
    #
    # Steps are:
    
    def initialize(patent)
      @pnum  = PatentNumber(patent)

      # objects to get the OPS, PTO and forward citations data
      ops_client   = OpsBiblioFamilyUrl.new(pnum, 1)
      pto_client   = PtoUrl.new(pnum, 2)
      fc_client    = PtoFCUrl.new(pnum, 1, 3)

      @hydra = PatentHydra.new(ops_client, pto_client, fc_client)
      run
    end

    def run
      res = @hydra.run

      ops_data = res.find{|o| o.job_id == 1}
      pto_data = res.find{|o| o.job_id == 2}
      
      @pto          = pto_data.to_pto_patent
      @family       = ops_data.to_ops_patent
      @ops          = @family.first

      fc           = PTO::ForwardCitation.new(pnum)
      fc_patents   = fc.get_full_fc
      
      result       = [pto, family, fc]
      self
    end

      # map the Claims structs to hashes
    def claims
      @claims ||= begin
        @claims = {}
        @pto.claims.each {|k,v| @claims[k] = v.to_hash }
        @claims
     end
    end

    def rationalize
      # brute force now
      p "Title: #{@pto.title == @ops.title}"
      p "Abstract: #{@pto.abstract == @ops.abstract}"
      p "Assignees: #{@pto.assignees}:#{@ops.assignees}"
      p "Filed: #{@pto.file_date}:#{@ops.file_date}"
      p "Inventors: #{@pto.inventors}:#{@ops.inventors}"
    end

    def patent
      @patent ||= (family[0].to_hash || {} )
    end

    def family; @family.members || []; end

    
    def pto; @pto || []; end
    

    private
      #
      # delegate calls for the fields to the PatentFields object
      #
      def method_missing(method, *args)
        return patent.send(method) if patent.respond_to?(method)
        super
      end

      def respond_to_missing?(method, include_private = false)
        patent.respond_to?(method) || super
      end
  end
end