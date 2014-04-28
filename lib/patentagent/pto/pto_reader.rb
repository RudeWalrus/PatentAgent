# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3
require 'patentagent'

module PatentAgent
  module PTO
    class PTOReader
      
      
      class << self
      include PatentAgent
      include Logging

      def read(num)
        get_from_url(patent_url(PatentNumber(num)))
      end

      def read_fc(num, page)
        get_from_url(fc_url(PatentNumber(num), page))
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
          log "#{e} for #{url}"
          nil
      end
    end
    end
  end
end
