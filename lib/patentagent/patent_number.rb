# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3

module PatentAgent
  
  class PatentNumber
    attr_reader   :cc, :number, :kind
    alias         :country_code :cc
    
    # error raised when passed a bad patent number
    InvalidPatentNumber = Class.new(RuntimeError)
    
    # #
    # # if passed a PatentNumber, just return it and don't create a new one
    # #
    # def self.new(arg)
    #   return arg if arg.class == self.class
    #   super
    # end

    def initialize(arg)
      @clean = arg.to_s
      @cc, @number, @kind   = PatentNumber.valid_patent_number(@clean)
      
      raise InvalidPatentNumber unless valid?

      rescue InvalidPatentNumber
        PatentAgent.log "Bogus patent number #{@clean}"
    end

    def to_patent; self;                           end

    def full;     "#{@cc}#{@number}";              end

    def to_s;     valid? ? @clean : "invalid";      end

    def valid?(); @number;                          end

    # figures out if a patent is published or not
    def self.is_published?(id, kind, country)
      return true if (country == "US" && id =~ /^[5678]\d{6}/)
      return true if (country == "US" && id =~ /^RE\d{5}/)  # ALLOW reissues to be valid published
      return true if (kind[0] =~ /^B/)
      return true if (kind[1].to_i > 1 )
      return false
    end

    #
    # returns an array where:
    #       =>  cc is country
    #       =>  number is number. 5 to 9 digits. Checked against US valid numbers too
    #       =>  kind is kind. This is something like A1 or B2
    #
    def self.valid_patent_number(num)
      pnum = cleanup_number(num)
      if pnum =~ /\A([A-Z]{2}|(?:USRE))?(\d{5,9})\.?([A-Z]\d)?\Z/ then
        cc      = get_country_code($1)
        number  = get_number($1,$2)
        kind    = $3 || ""  # if nil, set it to a blank
        
        # extra case to check for US ReIssue
        if cc == "US" then
          valid_us = valid_us_patent_number?(num) 
        else
          valid_us = true
        end
        
        if (cc && number && valid_us) then
          [cc,number,kind]
        else
          false
        end
      end
    end

    def self.valid_patent_number?(num)
      !!valid_patent_number(num)
    end

    #
    # convienece methods for getting part of a patent number
    #
    def self.cc_of(num);      n = valid_patent_number(num); n ? n[0] : "invalid" ;    end
    
    def self.number_of(num);  n = valid_patent_number(num); n ? n[1] : "invalid";     end
    
    def self.kind_of(num);    n = valid_patent_number(num); n ? n[2] : "invalid";     end
    
    private
      # formats the patent number to make it valid for HTML search
      #
      # accepts: US7,256,232.B1 or 7,256,232
      # returns: 7256232
      #
      def self.valid_us_patent_number?(num)
        pnum = cleanup_number(num)
        pnum.match(/(US)?([45678]\d{6})(\.[AB][12])?$|(US)?(RE\d{5}$)/) {|match| match[2] || match[5]}
      end
  
      #
      # A two letter country code like US, CA, JP, etc. Special case is RE,
      # which is a US re-issued patent. If RE, then its US.
      #
      def self.get_country_code(num)
        return "US" if num.nil?
        return "US" if num == "USRE"
        num.match(/([A-Z]{2})/) {|m| m[1] == "RE" ? "US" : m[1]} || "US"
      end

      def self.get_number(cc,num)
        return "RE#{num}" if (cc == "RE" || cc =="USRE")
        num
      end

      def self.cleanup_number(num); num.to_s.upcase.delete(",").delete(" ");        end
  end 

  #
  # coersion function for converting things to PatentNumbers
  module_function

  def PatentNumber(arg)
    case arg
    when PatentNumber           then arg
    when String, Integer        then PatentNumber.new(arg)
    when ->(n) {n.respond_to? :to_patent}
      arg.to_patent
    else
      raise TypeError, "Cannot convert #{arg.inspect} to PatentNumber"
    end
  end
end