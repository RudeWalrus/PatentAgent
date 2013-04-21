module PatentAgent
  module PTO
    class Client
      include PatentAgent::Logging
      
      PTOSRCHPATH = "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO1&Sect2=HITOFF&d=PALL&p=1&u=/netahtml/PTO/srchnum.htm&r=1&f=G&l=50&s1="

      def self.get_html(patent_number) 
        return unless patent_number && pat_num = valid_patent_number?(patent_number)
        url = PTOSRCHPATH + pat_num + ".PN.&OS=PN/" + pat_num + "&RS=PN/" + pat_num
        get_from_url(url) 
      end
      
      #
      # formats the patent number to make it valid for HTML search
      #
      # accepts: US7,256,232.B1 or 7,256,232
      # returns: 7256232
      #
      def self.valid_patent_number?(num)
        num.to_s.
          delete("US").
          delete(',').
          match(/([45678]\d{6})(\.[AB][12])?$|([Rr][Ee]\d{5}$)/) {|match| match[1] || match[3]}
      end
      
      private
      #
      # A wrapper for snarfing the HTML but its easy to stub it out for testing
      #
      def self.get_from_url(url)
        RestClient.get(url).to_str
        rescue => e
          log "#{e} for #{url}"
          nil
      end
    end
  end
end
