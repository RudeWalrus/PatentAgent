require 'patentagent'
require 'typhoeus'


module PatentAgent
  
  # stores the basics of a Typhoeus request
  # => url is a url string
  # => :method is :post or :get
  # => body should includes whatever needs to be sent (like the patent number)
  UrlRequest = Struct.new(:url, :method, :body) 
  
  class Client
    include PatentAgent
    attr_accessor :text, :valid, :patent, :job_id
 
    def initialize(patent, job_id = 1, options = {})
      @patent = PatentNumber(patent)
      @pnum   = @patent.number
      @job_id = job_id
    end
    def to_request; raise "Not implemented"; end
    def to_url; raise "Not implemented"; end
    def to_patent; raise "Not implmented"; end
    def number; patent.full; end
  end

  class OpsClient < Client
    include PatentAgent

    VER = "3.1"
  
    URL = {
      biblio:             "http://ops.epo.org/#{VER}/rest-services/published-data/publication/epodoc/biblio",
      family_biblio_doc:  "http://ops.epo.org/#{VER}/rest-services/family/publication/docdb/biblio",
      family_biblio:      "http://ops.epo.org/#{VER}/rest-services/family/publication/epodoc/biblio",
      family_biblio_ze:   "http://ops.epo.org/#{VER}/rest-services/family/publication/epodoc/",
      family_error:      "http://ops.epo.org/#{VER}/rest-services/family/",
      family_url:        "http://ops.epo.org/#{VER}/rest-services/family/publication/original/",

      fc:                "http://ops.epo.org/rest-services/published-data/search/",
      app:               "http://ops.epo.org/rest-services/published-data/application/epodoc/biblio",
      auth_url:          "https://ops.epo.org/#{VER}/auth/accesstoken"
    }

    class << self
      attr_accessor :id, :secret
    end

    def to_request()
     UrlRequest.new(to_url, :post, number)
    end

    # converts itself to an ops_patent
    #
    def to_patent
      OPS::OpsFamily.new(@patent, @text)
    end
  end

  class OpsBiblioFamilyClient < OpsClient
    def to_url
      URL[:family_biblio]
    end
  end

  class OpsBiblioClient < OpsClient
    def to_url
      URL[:biblio]
    end
  end

  class PtoClient < Client
    include PatentAgent
    
    def to_request()
      UrlRequest.new(to_url, :get, nil)
    end

    # converts itself to a PtoPatent
    #
    def to_patent
      PTO::PtoPatent.new(patent, text)
    end 
  end

  class PtoPatentClient < PtoClient
    PTO_SEARCH_URL = "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO1&Sect2=HITOFF&d=PALL&p=1&u=/netahtml/PTO/srchnum.htm&r=1&f=G&l=50&s1="

    def to_url
      url = PTO_SEARCH_URL + @pnum + ".PN.&OS=PN/" + @pnum + "&RS=PN/" + @pnum
    end
  end

  class PtoFCClient < PtoClient
    def initialize(patent, pg, job_id = 1)
      @pg = pg
      super(patent, job_id)
    end
    def to_url
      "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&p=#{@pg}&u=/netahtml/search-adv.htm&r=0&f=S&l=50&d=PALL&Query=ref/#{@pnum}"
    end
    def to_patent
      ForwardCitations.new(patent, text)
    end  
  end

  class FamiliesClient
    attr_reader :family, :results
    # takes an array of family members and fetches them from OPS
    #
    def initialize(list)
      # build a list of OPSUrl objects to fetch
      ops_urls = list.map{|patent| OpsBiblioFamilyUrl.new(patent)}
      @hydra = PatentHydra.new(ops_urls)
    end

    def run
      url_objects = @hydra.run
      @results = url_objects.map(&:to_ops_patent)
    end
  end
end