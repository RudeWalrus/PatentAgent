# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3

module PatentAgent
  module PTO

    class PTOReader
      include Logging
      
      def self.read(patent)
        url = PTOReader.patent_url(patent)
        new(patent, url).get_html
      end

      def self.read_fc(patent, page)
        url = PTOReader.fc_url(patent, page)
        new(patent, url).get_html
      end

      def initialize(patent, url)
        @patent = PatentNumber.new(patent)
        @url = url
      end

      def get_html
        return "Invalid patent address. No HTML" unless @patent && @patent.valid?
        get_from_url @url
      end
    	
      PTO_SEARCH_URL = "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO1&Sect2=HITOFF&d=PALL&p=1&u=/netahtml/PTO/srchnum.htm&r=1&f=G&l=50&s1="

      def self.patent_url(patent)
        pnum = PatentNumber.number_of patent
        url = PTO_SEARCH_URL + pnum + ".PN.&OS=PN/" + pnum + "&RS=PN/" + pnum
      end

      def self.fc_url(patent, pg)
        num = PatentNumber.number_of patent
        "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&p=#{pg}" + "&u=/netahtml/search-adv.htm&r=0&f=S&l=50&d=PALL&Query=ref/#{num}"
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
end
