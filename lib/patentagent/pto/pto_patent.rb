# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3


module PatentAgent
  module PTO
    class PtoPatent
      #
      # The basic patent parser class
      #
      include PatentAgent
      include Logging
      
      attr_reader :options, :html, :patent_num, :fields, :claims
      alias :name :patent_num

      extend Forwardable
      def_delegators :patent_num, :number, :kind, :cc

      # error raised when passed a bad patent number
      InvalidPatentNumber = Class.new(RuntimeError)
      
      def initialize(pnum, html, options = {})
        set_options(options)
        @patent_num = PatentNumber(pnum)
        #@html       = fetch(@patent_num)
        @html       = html
        @fields     = Fields.new(html)
        @claims     = Claims.new(html)
        log "Processed: #{@patent_num.to_s}"
        
        raise InvalidPatentNumber,"Invalid Patent #{pnum}" unless valid_patnum?

        rescue => error
          log "#{error}"
          @error = true
      end
      
      def set_options(opts)
        @options ||= {:debug => false, :fc => nil }
        @options.merge!(opts)
        self.debug = @options[:debug]
      end
      
      # def fetch(patent_number = @patent_num)
      #   PTOReader.read(patent_number)
      # end

      def valid_patnum?
        @patent_num && @patent_num.respond_to?(:valid?) && @patent_num.valid?
      end

      def valid?; !@error && valid_patnum? && !!@html; end
      
      def valid_html?; !!@html; end


      def to_hash; @fields.to_hash; end
      
      private
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