# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3
require "patentagent/reader"
require "patentagent/us/urls"

module PatentAgent
  module USPTO
    class ForwardCitation
      attr_reader :parent, :html, :url, :fc_references
      attr_reader :count, :pages
      #
      # Receives a patent number or PatentNum
      def initialize(parent)
        @parent        = PatentNumber.new(parent)
        @fc_references = []
      end

      def valid?
        @count
      end
      
      def fetch
        @fc_references = []

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

      def get_html(page=1)
        url   = URL.fc_url(@parent,page)
        html  = Reader.get_html(@parent, url)
        @html = clean_html(html)
      end

      #
      # gets the html from the PTO
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
        html.scan(/<a\s+href=[^>]*>([re\d,]+)<\/a>.*?>/mi).inject(@fc_references) {|o,m| o << m[0] }
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