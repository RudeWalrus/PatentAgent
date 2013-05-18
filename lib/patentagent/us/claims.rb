module PatentAgent
  class Claims < Hash
    attr_reader :total, :dep_count, :indep_count, :dep_claims, :indep_claims
    
    def initialize()
      @dep_claims, @indep_claims = [], [], []
      @total, @dep_count, @indep_count = 0, 0, 0
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
