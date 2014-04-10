# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3
require 'patentagent/patent_num_utils'

module PatentAgent
  
  class PatentNum
    include PatentNumUtils

    attr_reader  :country_code, :number, :kind
    
    # error raised when passed a bad patent number
    InvalidPatentNumber = Class.new(RuntimeError)

    def initialize(pat_num)
      @clean = pat_num.to_s
      @country_code, @number, @kind   = valid_patent_number?(pat_num)
      raise InvalidPatentNumber unless valid?

    rescue InvalidPatentNumber
      puts "Bogus patent number #{pat_num}"
    end 

    def to_s
      return "invalid" unless valid?
      @clean
    end

    def valid?
      @number
    end
  end 
end