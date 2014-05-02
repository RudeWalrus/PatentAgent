# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3
require 'patentagent'

module PatentAgent
  module PTO
    class PTOReader
      include PatentAgent
      
      attr_reader :valid, :text
      
      HTTPError = Class.new(RuntimeError)

      def initialize(num)
        @patent = PatentNumber(num)
      end

      def read
        @url = patent_url(@patent)
        @text = get_from_url()
          rescue => e
            "HTTP Error"
      end

      def read_fc(page)
        @url = fc_url(@patent, page)
        @text = get_from_url()
        rescue => e
            "HTTP Error"
      end


      def self.read(num)
        new(num).read
      end

      def self.read_fc(num, page)
        new(num).read_fc(page)
      end

      private
    	
      PTO_SEARCH_URL = "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO1&Sect2=HITOFF&d=PALL&p=1&u=/netahtml/PTO/srchnum.htm&r=1&f=G&l=50&s1="

      def patent_url(patent)
        pnum = PatentNumber.number_of patent
        url = PTO_SEARCH_URL + pnum + ".PN.&OS=PN/" + pnum + "&RS=PN/" + pnum
      end

      def fc_url(patent, pg)
        pnum = PatentNumber.number_of patent
        "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&p=#{pg}&u=/netahtml/search-adv.htm&r=0&f=S&l=50&d=PALL&Query=ref/#{pnum}"
      end
    	
      #
      # A wrapper for snarfing the HTML but its easy to stub it out for testing
      #
      def get_from_url(url = @url)
        RestClient.get(url).to_str
        rescue => e
          PatentAgent.log "#{e} for #{url}"
          raise HTTPError
      end
    end
  end
end
