# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3

module PatentAgent
  class ForwardCitations < Array
    include PatentAgent

    attr_reader :parent, :pages
    
    # Receives a patent number or PatentNum
    # param: html is the html of the first fc page from PTO (which has total count of fcs)
    def initialize(parent)
      @parent  = PatentNumber(parent)

      html_from_first_page = fetch_first_page

      # first compute counts(i.e. number of FCs)
      @count, @pages = compute_counts_from html_from_first_page
      
      fetch_remainder_from html_from_first_page
    end

    private
    
    def fetch_first_page
     ar = Hydra.new(PtoFCClient.new(@parent,1)).run
     ar[0].text
    end

    def fetch_remainder_from(html)
      # Each PTO page contains up to 50 citations so if counts > 50, then
      # we need to grab multiple pages. If so, grab the HTML for the pages
      html_objs     = get_html

      # do the first page from the @html passed in
      parse_fc_html(html)

      # and now the remainder from the Hydra
      html_objs.each{ |obj| parse_fc_html(obj.text) }
    end

    
    # gets pages 2 to ... n of a patents forward cites.
    def get_html
      return [] unless @pages > 1
      clients  = (2..@pages).map {|pg| PtoFCClient.new(@parent, pg)}
      Hydra.new(clients).run
    end
    
    #
    # computes the total forward references and the number of total pages
    #
    def compute_counts_from(html)
      text = clean_html(html)
      # snarf the count of total hits and hits on this page
      text.match(/hits \d+ through \d+.\s*out of (\d+)/mi) do |m|
        @count =  m[1].to_i
        @pages = (@count.to_f / 50.0).ceil.to_i
      end
      PatentAgent.dlog "Forward Citation for #{@parent} => Count: #{@count}: Pages: #{@pages}"
       [@count, @pages]
    end

    #
    # Parses the HTML
    # this is a really messy regex
    # it grabs the patent numbers and stores them
    def parse_fc_html(html)
      html.scan(/<a\s+href=[^>]*>([re\d,]+)<\/a>.*?>/mi).inject(self) {|o,m| o << m[0] }
    end
    #
    # strips out bold, italic and strong tags
    #
    def clean_html(string)
      string.gsub(/<\/?([bi]|strong)>/mi, "")
    end
  end
end