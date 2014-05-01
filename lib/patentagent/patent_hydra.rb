require 'typhoeus'


module PatentAgent
  class PatentHydra
    include Logging
    
    # used to cache patent request calls. Should speed up the
    # operation when lots of patents refer to the same references
    #
    # TODO: what I really want is an interface to a persistant cache
    # like Memcached. That way, data is stored between calls across
    # sessions. Figure out a way to use say Dalli and tie it to
    # Memcache but leave open other potential caches (even Mongo....)
    #
    class HydraCache
      def initialize;   @cache = {}; end
      def get(request); @cache[request]; end
      def set(request, response); @cache[request] = response; end
    end

    class << self
      attr_accessor :hydra

      def init_hydra
        return @hydra if @hydra
        @hydra = Typhoeus::Hydra.new(max_concurrency: 50) 
        Typhoeus::Config.memoize = true
        Typhoeus::Config.cache = HydraCache.new
        @hydra
      end
    end

    init_hydra


    # Expects a list of objects that respond to 
    # =>  #to_url 
    # =>  #to_request
    # These should be based on the OpsBaseURL and PtoBaseURL classes
    #
    def initialize(*list)
      #Make sure its an array and only take items that responds to #to_url
      @list = Array(list).flatten.select{|o| o.respond_to?(:to_url)}  
      @results = []
      @retry = []
    end
    
    USERAGENT = {"User-Agent" => "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.10) Gecko/20100915 Ubuntu/10.04 (lucid) Firefox/3.6.10" }

    def hydra
      self.class.hydra
    end

    # clears results and initiates a queue of requests for Hydra
    def queue(list=@list)
      @results = []
      @retry   = []
      add list
    end

    # list objects should respond to a #to_url message
    def add(list)
      list.each {|patent|
        request = request_from patent
        
        request.on_complete { |response|
          if response.success?
              patent.text = response.body
              #p "Hydra got: #{patent.patent.full}"
              @results << patent
          elsif response.timed_out?
              @retry << patent
          elsif response.code == 0
              puts "something is fucked up: #{patent.patent.full}"
              @retry << patent
          else
              puts 'HTTP Request failed: ' + response.code.to_s
          end
        } 

        hydra.queue( request )
        log "Queued: #{patent.patent.full} " + request.url
      }
    end

    def run
      queue
      hydra.run
      #
      #TODO: should check the @retry array and retry one time
      #
      if !@retry.empty?
        puts "There were errors. Should probably retry them"
      end

      @results
    end
    
    private
    def post(url, body)
      Typhoeus::Request.new(url, method: :post, body: body )
    end
    
    def get(url)
      Typhoeus::Request.new( url, method: :get )
    end
    # expects a UrlRequest object or something that responds to
    # an #url, #method and #body message
    def request_from(patent)
      req = patent.to_request
      if req.method == :post
        post(req.url, req.body)
      else # get
        get(req.url)
      end
    end
  end
end