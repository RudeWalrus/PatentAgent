# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3

module PatentAgent
  module PTO
    class ForwardCitation < Array
      attr_reader :parent, :html, :url, :fc_references
      attr_reader :count, :pages
      #
      # Receives a patent number or PatentNum
      def initialize(parent)
        @parent        = PatentNumber.new(parent)
      end

      def valid?
        self.count
      end
      
      def fetch

        # first grab the html and compute counts
        # the first grab will have the first page of data
        get_html(1)
        get_counts
        parse_fc_html
        
        # now do the remainder of the pages
        (2..@pages).each do |page|
          html = get_html(page)
          parse_fc_html(html)
        end

        self
      end

      private

      def get_html(page)
        html  = PTOReader.read_fc(@parent, page)
        @html = clean_html(html)
      end

      #
      # 
      #
      def get_counts(page=1)
        @count, @pages = compute_counts @html
      end

      
      #
      # Parses the HTML
      #
      def parse_fc_html(html=@html)
        # this is a really messy regex
        # it grabs the patent numbers and stores them in the 
        # @fc_references array patent numbers
        # 
        html.scan(/<a\s+href=[^>]*>([re\d,]+)<\/a>.*?>/mi).inject(self) {|o,m| o << m[0] }
      end
      
      #
      # computes the total forward references and the number of total pages
      #
      def compute_counts(html)
        # snarf the count of total hits and hits on this page
        html.match(/hits \d+ through \d+.\s*out of (\d+)/mi) do |m|
          count =  m[1].to_i
          pages = (count.to_f / 50.0).ceil
          [count, pages]
        end
      end

      #
      # strips out bold, italic and strong tags
      #
      def clean_html(string)
        string.gsub(/<\/?([bi]|strong)>/mi, "")
      end

    end
  end
end