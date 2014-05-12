# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3
require 'patentagent/util'
require 'typhoeus'
require "forwardable"

module PatentAgent  
  class Patent
    include PatentAgent::Util
    extend Forwardable
    
    attr_reader  :patent, :family, :pto, :fc, :claims, :ops, :family_members
    
    def_delegators :patent, :number, :cc, :kind
  
    def initialize(patent)
      @patent = PatentNumber(patent)

      # objects to get the OPS, PTO and forward citations data
      hydra = Hydra.new(
          OpsBiblioFamilyClient.new(patent, 1), 
          PtoPatentClient.new(patent, 2),
          PtoFCClient.new(patent, 1, 3)
      )
      kick_the hydra


    end

    def kick_the(hydra)
      res = hydra.run

      @family  = res.find_for_job_id(1).to_patent
      @pto     = res.find_for_job_id(2).to_patent
      @fc      = res.find_for_job_id(3).to_patent
      @ops     = @family
      #fc_patents   = fc.get_full_fc
      get_family_members
      # now get the actual patents from PTO for each family member
      
      result       = [pto, family, fc]
      self
    end

      # map the Claims structs to hashes
    def claims
      pto.claims
    end

    def rationalize
      # brute force now
      p "Title: #{@pto.title == @ops.title}"
      p "Abstract: #{@pto.abstract == @ops.abstract}"
      p "Assignees: #{@pto.assignees}:#{@ops.assignees}"
      p "Filed: #{@pto.file_date}:#{@ops.file_date}"
      p "Inventors: #{@pto.inventors}:#{@ops.inventors}"
    end

    def first; family[0].to_h || {}; end

    def family; @family.members || []; end
    
    def pto; @pto || []; end
    
    def to_h
      hash = {ops: @family.to_h}
      hash.merge!(pto: pto.to_h)
      hash.merge!(fc: fc)
    end
    
    def forward_citations
      @forward_cites ||= Fetcher.new(@patent, @fc).iterate
    end
    
    private

      def get_family_members
        @family_members ||= Fetcher.new(@patent, @family.us_family_issued).iterate
      end


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