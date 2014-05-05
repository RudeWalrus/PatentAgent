# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3

require "patentagent/patent_number"
require 'typhoeus'
require "forwardable"
require 'pry'

module PatentAgent  
  class Patent
    include PatentAgent
    extend Forwardable
    
    attr_reader  :patent, :family, :pto, :fc, :claims, :ops
    
    def_delegators :patent, :number, :cc, :kind
  
    def initialize(patent)
      @patent = PatentNumber(patent)

      # objects to get the OPS, PTO and forward citations data
      hydra = Hydra.new(
          OpsBiblioFamilyClient.new(patent, 1), 
          PtoPatentClient.new(patent, 2),
          PtoFCClient.new(patent, 1, 3)
      )
      run hydra
    end

    def run hydra
      res = hydra.run

      @family  = res.find_for_job_id(1).to_patent
      @pto     = res.find_for_job_id(2).to_patent
      @fc      = res.find_for_job_id(3).to_patent
      @ops     = @family
      #fc_patents   = fc.get_full_fc
      
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

    def first
      family[0].to_h || {}
    end

    def family; @family.members || []; end

    
    def pto; @pto || []; end
    
    def to_h
      hash = {ops: @family.to_h}
      hash.merge!(pto: pto.to_h)
      hash.merge!(fc: fc)
    end

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