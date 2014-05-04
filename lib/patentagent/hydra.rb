require 'typhoeus'

module PatentAgent
  class HydraArray < Array
    # convenience method to find a result by job_id
    def find_for_job_id(id)
      find{|o| o.job_id == id}
    end
  end

  class Hydra
    
    # used to cache patent request calls. Should speed up the
    # operation when lots of patents refer to the same references
    #
    # TODO: what I really want is an interface to a persistant cache
    # like Memcached. That way, data is stored between calls across
    # sessions. Figure out a way to use say Dalli and tie it to
    # Memcache but leave open other potential caches (even Mongo....)
    #
    class Cache
      def initialize;   @cache = {}; end
      def get(request); @cache[request]; end
      def set(request, response); @cache[request] = response; end
      def size; @cache.size; end
    end

    class << self
      attr_accessor :hydra
    end

    def self.init_hydra
      return @hydra if @hydra
      @hydra = Typhoeus::Hydra.new(max_concurrency: 50) 
      Typhoeus::Config.memoize = true
      Typhoeus::Config.cache = hydra_cache
      @hydra
    end

    def self.cache_size; hydra_cache.size || 0; end;

    def self.hydra_cache=(val); @hdyra_cache = val; end
    def self.hydra_cache; @hydra_cache ||= Cache.new; end

    init_hydra


    # Expects a list of objects that respond to 
    # =>  #to_request
    # These should implement interfaces that descend from the 
    # PatentAgent::Client class
    def initialize(*list)
      #Make sure its an array and only take items that responds to #to_request
      @list = Array(list).flatten.select{|o| o.respond_to?(:to_request)}  
      @results = HydraArray.new
      @retry = []
    end

    def hydra
      self.class.hydra
    end

    # clears results and initiates a queue of requests for Hydra
    def queue(list=@list)
      @results = HydraArray.new
      @retry   = []
      add list
    end

    # list is an arrays of patents. Each patent should respond to 
    # a #to_request message 
    def add(list)
      list.each {|patent|
        request = request_from patent
        
        request.on_complete { |response|
          #
          # TODO: replace this simple if-then-else with a case
          # and process the return values (specifically the 404s for OPS)
          if response.success?
              patent.text = response.body
              PatentAgent.log "Hydra got: #{patent.patent.full}"
              @results << patent
          elsif response.timed_out?
              @retry << patent
          elsif response.code == 0
              PatentAgent.log "something is fucked up: #{patent.patent.full}"
              @retry << patent
          else
              PatentAgent.log 'HTTP Request failed: ' + response.code.to_s + ' ' + response.body
          end
        } 

        hydra.queue( request )
        PatentAgent.log "Queued: #{patent.patent.full} " + request.url
      }
    end

    # @Returns: Array of enqueued patent_client objects
    def run
      queue
      hydra.run
      #
      #TODO: should check the @retry array and retry one time
      #
      if !@retry.empty?
        PatentAgent.log "There were errors. Should probably retry them"
      end

      @results
    end

    def fetch_single_item
      run
      @results[0]
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