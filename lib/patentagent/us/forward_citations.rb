module PatentAgent
  class ForwardCitation
    attr_reader :parent, :html, :url

    def initialize(parent)
      @parent = parent
    end

    def get_fc_html
      @url = PatentAgent::USUrls.fc_url(@parent,1)
      @html = PatentAgent::USClient.get_html(@parent, @url)
    end

    def valid?
      @html && @url
    end
  end
end