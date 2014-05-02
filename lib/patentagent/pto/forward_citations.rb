# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3

module PatentAgent
  module PTO
    class ForwardCitation < Array
      include PatentAgent
      include Logging

      attr_reader :parent, :html, :count, :pages
      attr_reader :patents, :names
      
      # Receives a patent number or PatentNum
      # param: html is the html of the first fc page from PTO (which has total count of fcs)
      def initialize(parent, html)
        @parent  = PatentNumber(parent)
        @patents = []
        @names   = []

        # first compute counts(i.e. number of FCs)
        @count, @page = compute_counts html
        fetch(html)
      end

      def get_full_fc
        # 
        # 1) get URLs for each patent number
        # 2) get the html for each patent (from the Hydra)
        # 3) turn the HTML into PTOPatent objects.
        url_objs   = urls_from @names
        html_objs  = html_from_urls url_objs
        patent_from_html html_objs
      end
      private

      def fetch(html)
        # Each PTO page contains up to 50 citations so if counts > 50, then
        # we need to grab multiple pages. If so, grab the HTML for the pages
        html_objs     = get_html

        # do the first page from the @html passed in
        parse_fc_html(html)

        # and now the remainder from the Hydra
        html_objs.each{ |obj| parse_fc_html(obj.html) }
      end

      # gets pages 2 to ... n of a patents forward cites.
      def get_html
        return [] unless @pages > 1
        clients  = (2..@pages).map {|pg| PtoFCUrl.new(@parent, pg)}
        PatentHydra.new(clients).run
      end
      
      #
      # computes the total forward references and the number of total pages
      #
      def compute_counts(html=@html)
        text = clean_html(html)
        # snarf the count of total hits and hits on this page
        text.match(/hits \d+ through \d+.\s*out of (\d+)/mi) do |m|
          @count =  m[1].to_i
          @pages = (count.to_f / 50.0).ceil.to_i
          [@count, @pages]
        end
        #p "Forward Citation for #{@parent} => Count: #{@count}: Pages: #{@pages}"
      end

      #
      # Parses the HTML
      # this is a really messy regex
      # it grabs the patent numbers and stores them
      def parse_fc_html(html=@html)
        html.scan(/<a\s+href=[^>]*>([re\d,]+)<\/a>.*?>/mi).inject(@names) {|o,m| o << m[0] }
      end
      #
      # strips out bold, italic and strong tags
      #
      def clean_html(string)
        string.gsub(/<\/?([bi]|strong)>/mi, "")
      end

      def urls_from(names)
        names.map{|patent| PtoUrl.new(patent)}
      end

      #
      # queues up a list of forward references to fetch
      # gets, them and creates PtoPatent objects from them
      def html_from_urls(url_objs)
        PatentHydra.new(url_objs).run
      end
      #
      # creates PtoPatent objects from each of the 
      def patent_from_html(objs)
        objs.map(&:to_pto_patent)
      end

      

    end
  end
end