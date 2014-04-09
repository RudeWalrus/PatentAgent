module PatentAgent

  Claim = Struct.new(:parent, :dep, :text)
  
  class Claims

    include Logging
    
    attr_reader :total, :dep_count, :indep_count, :dep_claims, :indep_claims
    
    # error raised when a bad claim is found
    MalformedClaim = Class.new(RuntimeError)
    
    def initialize(text)
      @dep_claims, @indep_claims = [], [], []
      @total, @dep_count, @indep_count = 0, 0, 0
      @text = text
      @parsed_claims = {}
    end
    
    def parse
      
      claim_text = @text[/(?:Claims<\/b><\/i><\/center> <hr>)(.*?)(?:<hr>)/mi]

      raise "No Claims" if claim_text.nil?
    
      # lets get the individual claims. The parens in the regex force the results to
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

    private
    
    def process(claim)
      # grab the claim number, parent and whether independant/dependant
      num    = claim[/^\d+/].to_i
      dep    = /claim (\d+)/.match(claim) 
      parent = dep.nil? ? num : dep[1].to_i
      
      if dep.nil?
        @indep_count += 1
        @indep_claims << num
      else
        @dep_count += 1
        @dep_claims << num
      end
      @total += 1
      @parsed_claims[num] = Claim.new(parent, dep, claim)
    end
    
    
   
  end
  
end
