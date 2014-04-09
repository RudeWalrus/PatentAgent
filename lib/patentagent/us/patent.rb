require "patentagent/util"
require "patentagent/logging"
require "patentagent/client"
require "patentagent/us/urls"
require "patentagent/us/fields"


module PatentAgent
  module USPTO
    # The basic patent parser class
    class Patent
      include Util
      include Logging

      attr_reader :options, :html, :patent_num, :fields, :claims
      
      # error raised when passed a bad patent number
      InvalidPatentNumber = Class.new(RuntimeError)
      
      def initialize(pnum, options = {})
        set_options(options)
        @patent_num = PatentNum.new(pnum)

        raise InvalidPatentNumber,"Invalid Patent #{pnum}" unless @patent_num.valid?
        
        rescue InvalidPatentNumber => e
           log "#{e}"
      end
      
      def self.fetch(pnum, options = {})
        patent = new(pnum, options)
        patent.fetch
      end

      def set_options(opts)
        @options ||= {:debug => false, :fc => nil }
        @options.merge!(opts)
        self.debug = @options[:debug]
      end
      
      def fetch(patent_number = @patent_num)
        url     = USPTO::URL.patent_url(patent_number)
        @html   = Client.get_html(patent_number, url)
        parse if @html
        self
      end
            
      def valid?
       @patent_num && !!@html
      end
      
      def valid_html?
        !!@html
      end
  
      def invalid_patent?
        !!@html[/No patents have matched your query/mi]
      end
      
      def parse
        @fields = Fields.new(self).parse
        @claims = Claims.new(@html).parse
        log "processed:", @patent_num
        self  
      end
      #
      # delegate calls for the fields to the PatentFields object
      #
      def method_missing(method, *args)
        return @fields.send(method) if @fields.respond_to?(method)
        super
      end
    end
  end   
end