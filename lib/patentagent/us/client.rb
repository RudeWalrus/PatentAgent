# The basic patent parser class

module PatentAgent
  class USClient
    include PatentAgent::Logging
    
    
    def self.get_html(patent_num, url) 
      return unless patent_num && patent_num.valid? && url
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
