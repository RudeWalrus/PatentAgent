require 'patentagent'
require 'typhoeus'


module PatentAgent

  class OpsBaseUrl
    include PatentAgent

    VER = "3.1"
  
    URL = {
      biblio:         "http://ops.epo.org/#{VER}/rest-services/published-data/publication/epodoc/biblio",
      family_biblio_doc:  "http://ops.epo.org/#{VER}/rest-services/family/publication/docdb/biblio",
      family_biblio:      "http://ops.epo.org/#{VER}/rest-services/family/publication/epodoc/biblio",
      family_biblio_ze:   "http://ops.epo.org/#{VER}/rest-services/family/publication/epodoc/",
      family_error:      "http://ops.epo.org/#{VER}/rest-services/family/",
      family_url:        "http://ops.epo.org/#{VER}/rest-services/family/publication/original/",

      fc:                "http://ops.epo.org/rest-services/published-data/search/",
      app:               "http://ops.epo.org/rest-services/published-data/application/epodoc/biblio",
      auth_url:          "https://ops.epo.org/#{VER}/auth/accesstoken"
    }

    attr_accessor :text, :valid, :patent
    
    class << self
      attr_accessor :id, :secret
    end

    def initialize(patent, auth=false)
      @patent = PatentNumber(patent)
      @pnum   = @patent.cc + @patent.number
    end

    def create_request()
     Typhoeus::Request.new(
       to_url,
       method: :post,
       body: @pnum
      )
    end
  end

  class OpsBiblioFamilyUrl < OpsBaseUrl
    def to_url
      URL[:family_biblio]
    end
  end

  class PtoBaseUrl
    include PatentAgent
    attr_accessor :text, :valid, :patent
    
    def initialize(patent)
      @patent = PatentNumber(patent)
      @pnum   = @patent.number
    end
    
    def to_url; raise "Not implemented"; end

    def create_request(); Typhoeus::Request.new( to_url ); end
  end

  class PtoUrl < PtoBaseUrl
    PTO_SEARCH_URL = "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO1&Sect2=HITOFF&d=PALL&p=1&u=/netahtml/PTO/srchnum.htm&r=1&f=G&l=50&s1="

    def to_url
      url = PTO_SEARCH_URL + @pnum + ".PN.&OS=PN/" + @pnum + "&RS=PN/" + @pnum
    end
  end

  class PtoFCUrl < PtoBaseUrl
    def initialize(patent, pg)
      @pg = pg
      super
    end
    def to_url
      "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&p=#{@pg}&u=/netahtml/search-adv.htm&r=0&f=S&l=50&d=PALL&Query=ref/#{@pnum}"
    end  
  end

  class PatentHydra
  
    # Expects a list of objects that respond to 
    # =>  #to_url 
    # =>  #create_request
    # These should be based on the OpsBaseURL and PtoBaseURL classes
    #
    def initialize(*list)
      @list = Array(list).flatten
      @results = []
      @retry = []
      init_hydra
    end
    
    class << self
      attr_accessor :hydra

      def init_hydra
        return if @hydra
        @hydra = Typhoeus::Hydra.new(max_concurrency: 40) 
        Typhoeus::Config.memoize = true
      end
    end

    def init_hydra
      self.class.init_hydra
    end

    def hydra
      self.class.hydra
    end

    # list objects should respond to a #url_for message
    def queue
      @results = []
      @retry   = []

      @list.each {
        |patent|
        # create request
        req = patent.create_request
        req.on_complete {
          |resp|
          if resp.success?
              patent.text = resp.body
              @results << patent
          elsif resp.timed_out?
              @retry << patent
          elsif resp.code == 0
              #something is fucked up
          else
              puts 'HTTP Request failed: ' + res.code.to_s
          end
        } 

        hydra.queue( req )
        puts 'Queued: ' + req.url
      }
    end

    def run
      queue
      hydra.run
      #
      #TODO: should check the @retry array and retry one time
      #
      @results
    end
  end

  class Client
    include Typhoeus
    
    attr_accessor :hydra
    attr_reader :list, :results, :ops, :pto

    #
    # get the patent info for patent
    #
    # Steps are:
    # => 1) In parallel
    #   a)Get OPS family-biblio for the patent
    #   b)Get OPS family-biblio for the patent
    
    # def initialize(*patent)
    #   @list    = Array(patents).flatten
    #   @results = []
    #   hydra = PatentHydra.new(list)
    # end
    def initialize(patent)
      @ops = OpsBiblioFamilyUrl.new(patent)
      @pto = PtoUrl.new(patent)

      @hydra= PatentHydra.new(ops, pto)
    end
    def run
      @hydra
      res = @hydra.run

      pto = res[0]
      ops = res[1]

      @pto_patent = PTO::PtoPatent.new(pto.patent, pto.text)
      @ops_patent = OPS::OpsPatent.new(ops.patent, ops.text)
    end
  end
end