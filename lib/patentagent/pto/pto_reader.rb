# The basic patent parser class

module PatentAgent
  module PTO
    extend self
    
    PTOSRCHPATH = "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO1&Sect2=HITOFF&d=PALL&p=1&u=/netahtml/PTO/srchnum.htm&r=1&f=G&l=50&s1="

    def get_html(patent_number) 
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
    def valid_patent_number?(num)
      number = num.to_s.delete("US").delete(',')
      return $1 || $3 if number.match /([45678]\d{6})(\.[AB][12])?$|([Rr][Ee]\d{5}$)/
      return nil
  	end
  	
  	private
    #
    # A wrapper for snarfing the HTML but its easy to stub it out for testing
    #
    def get_from_url(url)
      RestClient.get(url).to_str
      rescue => e
        PatentAgent.log "#{e} for #{url}"
        nil
    end
  end
end
