module PatentAgent
  class Fetcher < Array
    include PatentAgent::Util

    attr_accessor :parent, :names
    
    # Receives:
    # param:  parent: a patent number or PatentNum
    # param:  names: a list or array of patent numbers
    def initialize(parent, *list)
      @parent  = PatentNumber(parent)
      @names   = PatentNumber(Array(list).flatten)
      #iterate(names)
    end

    def iterate(names)
      # 1) get URLs for each patent number
      # 2) get the html for each patent (from the Hydra)
      # 3) turn the HTML into PTOPatent objects.
      url_objs   = urls_from names
      text_objs  = text_from_urls url_objs
      patent_from_text text_objs
    end

    private

    def urls_from(names)
      names.map{|patent| PtoPatentClient.new(patent)}
    end

    #
    # queues up a list of forward references to fetch & gets them
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