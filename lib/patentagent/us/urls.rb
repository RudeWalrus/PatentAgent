# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3

require "patentagent/patent_num"

module PatentAgent
  module USPTO
    module URL
      PTOSRCHPATH = "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO1&Sect2=HITOFF&d=PALL&p=1&u=/netahtml/PTO/srchnum.htm&r=1&f=G&l=50&s1="
      
      def self.patent_url(patent)
        pnum = get_num_part_of_patent(patent)
        url = PTOSRCHPATH + pnum + ".PN.&OS=PN/" + pnum + "&RS=PN/" + pnum
      end

      def self.fc_url(patent, pg=1)
        num = get_num_part_of_patent(patent)
        "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&p=#{pg}&u=/netahtml/search-adv.htm&r=0&f=S&l=50&d=PALL&Query=ref/#{num}"
      end

      protected
      def self.get_num_part_of_patent(num)
        return PatentNum.new(num).number
      end
    end
  end
end