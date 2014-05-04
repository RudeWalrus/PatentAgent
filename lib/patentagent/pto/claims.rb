# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3

module PatentAgent
  module PTO
    Claim = Struct.new(:parent, :dep, :text)

    class Claims < Hash
      attr_reader :total, :dep_count, :indep_count
      attr_reader :dep_claims, :indep_claims

      alias :count :total
      
      # error raised when a bad claim is found
      MalformedClaim = Class.new(RuntimeError)
      NoClaims       = Class.new(RuntimeError)
      
      def initialize(html = :html_error)
        @dep_claims, @indep_claims = [], []
        @total, @dep_count, @indep_count = 0, 0, 0
        
        parse  html 
      end
      
      def count;      @total;      end

      #
      # parses all the claims
      #
      def parse(text)
        claim_text = text[/(?:Claims<\/b><\/i><\/center> <hr>)(.*?)(?:<hr>)/mi]

        raise NoClaims if claim_text.nil?
      
        # get the individual claims. The parens in the regex force the results to
        # be placed into a capture group (an array within the array). The claim is element
        # 0 of this array
        m = claim_text.scan( /<br><br>\s*(\d+\..*?)((?=<br><br>\s*\d+\.)|(?=<hr>))/mi)

        raise MalformedClaim, "Bad Claim in patent: #{pnum}" if m.nil?

        # process each claim
        m.each{ |claim| process(claim[0].gsub("\n", " ").gsub(/<BR><BR>/, " ")) }

        PatentAgent.dlog "Claims:" , {count: @count, indep: @indep_count, dep: @dep_count, claims: self }
        
        self

        rescue NoClaims => e
          PatentAgent.log "No claims found: #{e}"
          return ["Not found"]

        rescue RuntimeError => e
          PatentAgent.log "Error in claims parsing. #{e}"
          return ["Not found"]
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
        self[num] = Claim.new(parent, dep, claim)
      end
    end
  end
end
