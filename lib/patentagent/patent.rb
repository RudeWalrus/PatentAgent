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
    
    attr_accessor  :patent, :results, :family, :pto, :fc, :claims

    def_delegators :patent, :number, :cc, :kind
  
    def initialize(patent)
      @patent = PatentNumber(patent)

      # objects to get the OPS, PTO and forward citations data
      @hydra = Hydra.new(
          OpsBiblioFamilyClient.new(patent, 1), 
          PtoPatentClient.new(patent, 2),
          PtoFCClient.new(patent, 3)
      )
      run
    end

    def run
      res = @hydra.run

      @family  = res.find_for_job_id(1).to_patent
      @pto     = res.find_for_job_id(2).to_patent
      binding.pry
      @fc      = res.find_for_job_id(3).to_patent
      @ops     = @family.first

      @fc           = fc_data.to_patent
      #fc_patents   = fc.get_full_fc
      
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