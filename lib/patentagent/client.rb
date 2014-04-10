# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3

require "patentagent/logging"

module PatentAgent
    class Client
      include Logging
      
      def self.get_html(patent, url) 
        new(patent, url).get_html
      end

      def initialize(patent, url)
        @patent = patent
        @url = url
      end

      def get_html(patent=@patent, url = @url)
        return unless patent && patent.valid? && url
        get_from_url(url) 
      end
    	
    	private
      #
      # A wrapper for snarfing the HTML but its easy to stub it out for testing
      #
      def get_from_url(url = @url)
        RestClient.get(url).to_str
        rescue => e
          log "#{e} for #{url}"
          nil
      end
    end
end
