module PatentAgent
  class Claims < Hash
    attr_reader :total, :dep_count, :indep_count, :dep_claims, :indep_claims
    
    # error raised when a bad claim is found
    class MalformedClaim < RuntimeError; end
    
    def initialize()
      @dep_claims, @indep_claims = [], [], []
      @total, @dep_count, @indep_count = 0, 0, 0
    end
    
    def parse_claims(text)
      
      claim_text = text[/(?:Claims<\/b><\/i><\/center> <hr>)(.*?)(?:<hr>)/mi]

      raise "No Claims" if claim_text.nil?
    
      # lets get the individual claims. The parens in the regex force the results to
      # be placed into a capture group (an array within the array). The claim is element
      # 0 of this array
      m = claim_text.scan( /<br><br>\s*(\d+\..*?)((?=<br><br>\s*\d+\.)|(?=<hr>))/mi)

      raise MalformedClaim, "Bad Claim Patent #{pnum}" if m.nil?

      # collect the claims into an array
      m.each { |claim| @claims << claim[0].gsub("\n", " ").gsub(/<BR><BR>/, " ") }

      result = {count: claims.count, indep: claims.indep_count, dep: claims.dep_count, claims: claims }
      log "Claims:" , result
      
      rescue RuntimeError => e
        log "Error in claims parsing. #{e}"
        return ["Not found"]
    end

    
    def <<(claim)
      # grab the claim number, parent and whether independant/dependant
      num = claim[/^\d+/].to_i
      dep =  /claim (\d+)/.match(claim) 
      parent = dep.nil? ? num : dep[1].to_i
      if dep.nil?
        @indep_count += 1
        @indep_claims << num
      else
        @dep_count += 1
        @dep_claims << num
      end
      @total += 1
      self[num] = {num: num, parent: parent, claim: claim}
    end
    
    def count
      @total
    end
      
    alias_method :add, :<<
  end
  
end
