module PatentAgent
class ForwardCitationPatents < Array
    include PatentAgent

    attr_accessor :parent, :names
    
    # Receives:
    # param:  parent: a patent number or PatentNum
    # param:  names: a ForwardCitations object or array of patent numbers
    def initialize(parent, names)
      @parent  = PatentNumber(parent)
      #names    =  ForwardCitations(names)  # TODO: implement this coersion/error check class later
      @names   = PatentNumber(names)
      #iterate(names)
    end

    def iterate(names)
      # 
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
end