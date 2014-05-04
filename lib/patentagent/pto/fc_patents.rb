module PTO
class ForwardCitationPatents < Array
    include PatentAgent

    attr_reader :parent
    
    # Receives:
    #   parent: a patent number or PatentNum
    # => names: a ForwardCitations object or array of patent numbers
    # param: html is the html of the first fc page from PTO (which has total count of fcs)
    def initialize(parent, names)
      @parent  = PatentNumber(parent)
      #names    =  ForwardCitations(names)  # TODO: implement this coersion/error check class later

      fc_patents(names)
    end

    def fc_patents(names)
      # 
      # 1) get URLs for each patent number
      # 2) get the html for each patent (from the Hydra)
      # 3) turn the HTML into PTOPatent objects.
      url_objs   = urls_from names
      html_objs  = html_from_urls url_objs
      patent_from_html html_objs
    end
    private

    def urls_from(names)
      names.map{|patent| PtoClient.new(patent)}
    end

    #
    # queues up a list of forward references to fetch
    # gets, them and creates PtoPatent objects from them
    def html_from_urls(url_objs)
      Hydra.new(url_objs).run
    end
    #
    # creates PtoPatent objects from each of the 
    def patent_from_html(objs)
      objs.map(&:to_pto_patent)
    end
  end
end