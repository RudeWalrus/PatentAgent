module PatentAgent
  class ForwardCitation
    attr_reader :parent, :html, :url, :fc_references
    attr_reader :count, :pages

    def initialize(parent)
      @parent = parent
      @fc_references = []
    end

    def get_fc_html
      @url = PatentAgent::USUrls.fc_url(@parent,1)
      @html = PatentAgent::USClient.get_html(@parent, @url)
      @count, @pages = compute_counts @html
    end

    def valid?
      @html && @url
    end
    
    def get_references
        @pages.times do |page|
          puts "Page: #{page}"
        end
    end

    def parse_fc_html html=@html
      # this is a really mess regex
      # it grabs the patent number and stores  the patent numbers
      # 
      html.scan(/<a\s+href=[^>]*>([re\d,]+)<\/a>.*?>/mi).inject(@fc_references) {|o,m| o << m[0] }
    end

    def get_page page
      []
    end

    private 

      def compute_counts(string)
        # first, remove bold, italic and strong tags
        clean = string.gsub(/<\/?([bi]|strong)>/i, "")

        # now grab the count of total hits and hits on this page
        clean.match(/hits \d+ through \d+.\s*out of (\d+)/mi) do |m|
          count =  m[1].to_i
          pages = (count.to_f / 50.0).ceil
          [count, pages]
        end
      end

      
  end
end