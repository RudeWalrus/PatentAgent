# The basic patent parser class

module PatentAgent
  module PTO
    class Reader
      include PatentAgent::Logging
      
      PTOSRCHPATH = "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO1&Sect2=HITOFF&d=PALL&p=1&u=/netahtml/PTO/srchnum.htm&r=1&f=G&l=50&s1="

      def self.get_html(patent_num) 
        return unless patent_num && patent_num.valid?
        pnum = patent_num.number
        url = PTOSRCHPATH + pnum + ".PN.&OS=PN/" + pnum + "&RS=PN/" + pnum
        get_from_url(url) 
      end
      
    	
    	private
      #
      # A wrapper for snarfing the HTML but its easy to stub it out for testing
      #
      def self.get_from_url(url)
        RestClient.get(url).to_str
        rescue => e
          PatentAgent::Logging.log "#{e} for #{url}"
          nil
      end
    end
  end
end
