module PatentAgent
  class Fetcher < Array
    include PatentAgent::Util

    attr_accessor :parent, :names, :client
    
    # Receives:
    # param:  parent: a patent number or PatentNum
    # param:  names: a list or array of patent numbers
    def initialize(parent, *list)
      type = list.pop if list.last.is_a?(Hash)

      if type.nil?
        @client = PtoPatentClient
      else
        @client = type[:client]
      end

      @parent  = PatentNumber(parent)
      @names   = PatentNumber(Array(list).flatten)
      #iterate(names)
    end

    def iterate(names=@names)
      # 1) get URLs for each patent number
      # 2) get the html for each patent (from the Hydra)
      # 3) turn the HTML into PTO, Patent objects.
      urls   = urls_from names
      texts  = text_from_urls urls
      patent_from_text texts
    end

    private

    def urls_from(names)
      names.map{|patent| @client.new(patent)}
    end

    #
    # queues up a list of items to fetch & gets them
    def text_from_urls(url_objs)
      Hydra.new(url_objs).run
    end
    #
    # creates patent objects from objs
    def patent_from_text(list)
      objs = Array(list)
      objs.map(&:to_patent)
    end
  end

  class PtoPatentFetcher < Fetcher
    def urls_from(names)
      names.map{|patent| PtoPatentClient.new(patent)}
    end
  end
  
  class OpsPatentFetcher < Fetcher
    def urls_from(names)
      names.map{|patent| OpsBiblioFamilyClient.new(patent)}
    end
  end

end