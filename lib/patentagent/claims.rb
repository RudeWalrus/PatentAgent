# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3

module PatentAgent

  Claim = Struct.new(:parent, :dep, :text) do
    def to_hash; {parent: parent, dep: dep, text: text }; end
  end
  
  class Claims
    include Logging
    include Enumerable

    attr_reader :total, :dep_count, :indep_count, :dep_claims, :indep_claims, :parsed_claims

    alias :count :total
    
    # error raised when a bad claim is found
    MalformedClaim = Class.new(RuntimeError)
    
    def initialize(text)
      @dep_claims, @indep_claims = [], []
      @total, @dep_count, @indep_count = 0, 0, 0
      @text = text
      @parsed_claims = {}
    end
    
    #
    # parses all the claims
    #
    def parse(text = @text)
      
      claim_text = text[/(?:Claims<\/b><\/i><\/center> <hr>)(.*?)(?:<hr>)/mi]

      raise "No Claims" if claim_text.nil?
    
      # get the individual claims. The parens in the regex force the results to
      # be placed into a capture group (an array within the array). The claim is element
      # 0 of this array
      m = claim_text.scan( /<br><br>\s*(\d+\..*?)((?=<br><br>\s*\d+\.)|(?=<hr>))/mi)

      raise MalformedClaim, "Bad Claim in patent: #{pnum}" if m.nil?

      # process each claim
      m.each{ |claim| process(claim[0].gsub("\n", " ").gsub(/<BR><BR>/, " ")) }

      log "Claims:" , {count: @count, indep: @indep_count, dep: @dep_count, claims: self }
      
      self

      rescue RuntimeError => e
        log "Error in claims parsing. #{e}"
        return ["Not found"]
    end

    def count
      @total
    end

    def [](index)
      @parsed_claims[index]
    end

    #
    # convinience method that iterates over the claims hash
    # and returns the claim text
    # @return [String]
    def each(&block)
      @parsed_claims.each { |key, obj| block.call(key, obj)}
    end

    private
    
    def process(claim)
      # grab the claim number, parent and whether independant/dependant
      num     = claim[/^\d+/].to_i
      dep_num = claim.match(/claim (\d+)/)
      dep     = !!dep_num
      parent  = dep_num.nil? ? num : dep_num[1].to_i
      
      if dep
        @dep_count += 1
        @dep_claims << num
      else
        @indep_count += 1
        @indep_claims << num
      end
      
      @total += 1
      @parsed_claims[num] = Claim.new(parent, dep, claim)
    end
  end

end
