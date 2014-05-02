require 'patentagent'
require 'typhoeus'


module PatentAgent
  UrlRequest = Struct.new(:url, :method, :body) 
  
  class OpsBaseUrl
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

    attr_accessor :text, :valid, :patent, :job_id
    alias :xml :text
    
    class << self
      attr_accessor :id, :secret
    end

    def initialize(patent, job_id=1, options ={})
      @patent = PatentNumber(patent)
      @pnum   = @patent.cc + @patent.number
      @job_id = job_id
    end

    def to_request()
     UrlRequest.new(to_url, :post, @pnum)
    end

    # converts itself to an ops_patent
    #
    def to_ops_patent
      OPS::OpsFamily.new(@patent, @text)
    end
    
    def number; @patent.full; end
  end

  class OpsBiblioFamilyUrl < OpsBaseUrl
    def to_url
      URL[:family_biblio]
    end
  end

  class OpsBiblioUrl < OpsBaseUrl
    def to_url
      URL[:biblio]
    end
  end

  class PtoBaseUrl
    include PatentAgent
    attr_accessor :text, :valid, :patent, :job_id
    alias :html :text

    def initialize(patent, job_id = 1, options = {})
      @patent = PatentNumber(patent)
      @pnum   = @patent.number
      @job_id = job_id
    end
    
    def to_url; raise "Not implemented"; end

    def to_request()
      UrlRequest.new(to_url, :get, nil)
  end

    # converts itself to a PtoPatent
    #
    def to_pto_patent
      PTO::PtoPatent.new(@patent, @text)
    end

    def number; @patent.full; end
  end

  class PtoUrl < PtoBaseUrl
    PTO_SEARCH_URL = "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO1&Sect2=HITOFF&d=PALL&p=1&u=/netahtml/PTO/srchnum.htm&r=1&f=G&l=50&s1="

    def to_url
      url = PTO_SEARCH_URL + @pnum + ".PN.&OS=PN/" + @pnum + "&RS=PN/" + @pnum
    end
  end

  class PtoFCUrl < PtoBaseUrl
    def initialize(patent, pg, job_id = 1)
      @pg = pg
      super(patent, job_id)
    end
    def to_url
      "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&p=#{@pg}&u=/netahtml/search-adv.htm&r=0&f=S&l=50&d=PALL&Query=ref/#{@pnum}"
    end  
  end

  class Client
    include Typhoeus
    
    attr_accessor :hydra
    attr_accessor :patent, :results, :ops, :pto, :fc

    #
    # get the patent info for patent
    #
    # Steps are:
    
    def initialize(patent)
      @patent = patent
      @ops    = OpsBiblioFamilyUrl.new(patent, 1)
      @pto    = PtoUrl.new(patent, 2)
      @fc     = PtoFCUrl.new(patent, 1, 3)

      @hydra= PatentHydra.new(ops, pto, fc)
    end

    def run
      res = @hydra.run

      ops = res.find{|o| o.job_id == 1}
      pto = res.find{|o| o.job_id == 2}
      #fc  = res.find{|o| o.job_id == 3}
      
      pto_data     = pto.to_pto_patent
      ops_data     = ops.to_ops_patent
      #fc_initial   = fc.to_pto_patent

      fc_data = PTO::ForwardCitation.new(patent)
      #fc_data.names.each{|x| p x }
      fc_patents = fc_data.get_full_fc
      #fc_patents.each {|x| p x.claims.inspect}
      
      result = [pto_data, ops_data, fc_data]
    end
  end

  class FamilyClient
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

    class FCClient
      attr_reader  :results
      # takes an array of family members and fetches them from OPS
      #
      def initialize(list)
        # build a list of OPSUrl objects to fetch
        pto = list.map{|patent| OpsBiblioFamilyUrl.new(patent)}
        @hydra = PatentHydra.new(ops_urls)
      end

      def run
        url_objects = @hydra.run
        @results = url_objects.map(&:to_ops_patent)
      end
    end
  end
end