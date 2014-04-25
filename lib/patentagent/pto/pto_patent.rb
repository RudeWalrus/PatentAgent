# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3


module PatentAgent
  module PTO
    class PTOPatent
      #
      # The basic patent parser class
      #
      include Logging
      
      attr_reader :options, :html, :patent_num, :fields, :claims
      alias :name :patent_num

      extend Forwardable
      def_delegators :patent_num, :number, :kind, :cc

      # error raised when passed a bad patent number
      InvalidPatentNumber = Class.new(RuntimeError)
      
      def initialize(pnum, options = {})
        set_options(options)
        @patent_num = PatentNumber.new(pnum)
        @fields = Fields.new
        @claims = Claims.new

        raise InvalidPatentNumber,"Invalid Patent #{pnum}" unless valid_patnum?

        rescue InvalidPatentNumber => error
          log "#{error}"
      end
      
      def set_options(opts)
        @options ||= {:debug => false, :fc => nil }
        @options.merge!(opts)
        self.debug = @options[:debug]
      end
      
      def fetch(patent_number = @patent_num)
        if html
          @fields.set_src(@html).parse
          @claims.set_src(@html).parse
        end
        log "processed:", patent_number
        self
      end

      def valid_patnum?
       @patent_num && @patent_num.respond_to?(:valid?)
      end

      def valid?
       valid_patnum? && !!@html
      end
      
      def valid_html?
        !!@html
      end

      def invalid_patent?
        !!@html[/No patents have matched your query/mi]
      end

      def to_hash
        @fields.to_hash
      end
      
      private
      
      def html(patent_number = @patent_num)
        #url     = USPTO::URL.patent_url(patent_number)
        @html ||= PTOReader.read(patent_number)
      end
      #
      # delegate calls for the fields to the PatentFields object
      #
      def method_missing(method, *args)
        return @fields.send(method) if @fields.respond_to?(method)
        super
      end

      def respond_to_missing?(method, include_private = false)
        @fields.respond_to?(method) || super
      end
    end
  end   
end