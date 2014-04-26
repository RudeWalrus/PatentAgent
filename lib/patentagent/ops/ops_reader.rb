require 'nokogiri'
require 'rest-client'
require 'json'
require 'base64'
require 'patentagent/patent_number'
require 'patentagent/logging'


module PatentAgent
  module OPS
  class Reader
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
    
    attr_reader :doc_num, :biblio, :family, :fc, :error_state, :auth
  
    #
    # Takes a patent number and a hash of nodes
    def initialize(patent, args)
      
      # do we need to authorize?
      @auth = args.fetch(:auth) { false }

      @doc_num = PatentNumber.new(patent)
      if @auth
        @token = Reader.get_oauth_token
      end
    end
  
    def read(num = @doc_num)
      patent = num.to_s
      # fetch the bibilo, family, and forward citation data from EPO
      @biblio = Reader.get(:biblio, patent) or raise "Failed to fetch patent biblio"
      @family = Reader.get(:family_biblio, patent) or raise "Failed to fetch Family_Biblio"
      @fc     = Reader.get(:fc, patent) or raise "Failed to fetch forward citations"
      self
      rescue => e
        raise unless e.message =~ /Failed to fetch/
        @error_state = true
        p "Error: #{e.message}"
    end

    def self.read(patent, options)
      new(patent, options).read
    end
  
    def data
      [@biblio, @family, @fc]
    end
  
    # 
    # OPS rate limits access. However, one can register for an account
    # To do so requires an OAuth key exchange (registering grants the user
    # a set of secret keys to be exchanged for a Bearer token key)
    #
    # @returns (string: token for authorization)
    def self.get_oauth_token(id=nil, secret=nil)
      id     ||= ENV["OPS_CONSUMER_KEY"]
      secret ||= ENV["OPS_SECRET_KEY"]

      # OPS expects the id and secret to be sent as a string, seperated by :
      # and base64 encoded using HTTP Basic Authentication 
      # 
      auth = Base64.encode64("#{id}:#{secret}")
      p "fetching auth token for #{id}:#{secret}"
      @oauth  = RestClient.post(URL[:auth_url], 
        "grant_type=client_credentials",
        Authorization: auth, content_type: "application/x-www-form-urlencoded"
      )

      token = JSON.parse(@oauth)["access_token"]
      p "Authorizaton token is valid: #{token}"
      token
    end

    
  
    def self.get(type, id)
      case type
      when :biblio, :family, :family_biblio, :family_biblio_doc
        get_xml(URL[type], id) 
      when :fc
        get_xml(URL[type], make_ops_forward_cite_url(id))
      end
    end
    
    private
    #
    # Find the referenced patent in the family biblio. The wrinkle here is that occasionally
    # a family is really long. The EPO seems to cut-off biblio information after the 100th family
    # member. So, check to see if the returned result is nil and if it is, fetch the straight biblio
    #
    def find_biblio
      biblio =  family.css('exchange-document').select {|x| x["doc-number"] == doc_number[2..-1]}
      if biblio.nil? || biblio[0].nil? 
        p "Patent #{doc_number} family - biblio too long, fetching biblio"
        fetch(:biblio, doc_number)
      else
        biblio[0]
      end
    end
  
    def self.get_xml(url, doc_number, authorize = false)
      p "Fetching: #{url} => #{doc_number}"

      if authorize
        auth = "Bearer #{@token}"
        response = RestClient.post(url, doc_number, Authorization: auth) 
      else
        response = RestClient.post(url, doc_number)
      end
      result = Nokogiri::HTML(response)

      rescue => e
        p error = "for #{url} @ #{doc_number}\n ==> #{e.response}"
        case e.response.code
          when 403
            p "-EPO Robot #{error}"
          when 413
            p "-Ambiguous Response"
            p "RE-LOAD value ===> #{url}"
            source = retry_ambiguous_response(e.response)
          when 503
            p "EPO Server Timeout: #{error}"
          else
            p "EPO Error: #{e.response.code} #{error}"
        end
        @error_state = true
        result
    end

    def self.retry_ambiguous_response response
      resp        =  Nokogiri::HTML(response)
      resp.css("cause").text.match /Ambiguous/
      resolution  = resp.css("resolution").last.text
      source      = RestClient.get(URL[:family_error] + resolution)
    end

    def self.make_ops_forward_cite_url(doc_number)
      %w[ct ex op rf oc].map{|x| "#{x}%3D#{doc_number}"}.join(" or ")
    end
  end
end
end