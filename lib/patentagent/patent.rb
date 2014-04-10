# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3

require "patentagent/patent_num"

module PatentAgent    
  class Patent
    
    attr_reader :number, :title, :abstract, :assignee, :app_number
    attr_reader :inventors, :priority_date
    
    def initialize(*patents)
      result = patents.each do |patent|
        patent  = PatentNum.new(patent) if patent.is_a?(String) 
        @number = patent
      end    
    end
    
    def self.config(pnum, opts = {})
      yield self if block_given?
    end

    def valid?
      @number && @number.valid?
    end

    def fetched?
      number && inventors && priority_date
    end
  end
end
