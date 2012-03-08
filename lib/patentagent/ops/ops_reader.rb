require 'nokogiri'


module PatentAgent
  module OPS
    class Reader
    
      BIBLIO_URL        = "http://ops.epo.org/2.6.2/rest-services/published-data/publication/epodoc/biblio"
      FAMILY_BIBLIO_DOC = "http://ops.epo.org/2.6.2/rest-services/family/publication/docdb/biblio"
      FAMILY_BIBLIO     = "http://ops.epo.org/2.6.2/rest-services/family/publication/epodoc/biblio"
      FAMILY_BIBLIO_EZ  = "http://ops.epo.org/2.6.2/rest-services/family/publication/epodoc/"
      FAMILY_ERROR      = "http://ops.epo.org/2.6.2/rest-services/family/"
      FAMILY_URL        = "http://ops.epo.org/2.6.2/rest-services/family/publication/original/"

      FC                = "http://ops.epo.org/2.6.2/rest-services/published-data/search/"
      APP               = "http://ops.epo.org/2.6.2/rest-services/published-data/application/epodoc/biblio"

      attr_reader :doc_num, :biblio, :family, :fc, :error_state
    
      def initialize(patent, nodes)
        @doc_num = patent
      
        # fetch the bibilo, family, and forward citation data from EPO
        @biblio = nodes[:biblio] 
        @family = nodes[:family] 
        @fc     = nodes[:fc]
      end
    
      def self.read(patent)
        # fetch the bibilo, family, and forward citation data from EPO
        biblio = get(:biblio, patent) or raise "Failed to fetch patent biblio"
        family = get(:family_biblio, patent) or raise "Failed to fetch Family_Biblio"
        fc     = get(:fc, patent) or raise "Failed to fetch forward citations"
      
        new(patent, :biblio => biblio, :family => family, :fc => fc)
      
        rescue => e
          raise unless e.message =~ /Failed to fetch/
          @error_state = true
          puts "Error: #{e.message}"
      end
    
      def data
        [@biblio, @family, @fc]
      end
    
      protected
    
      class << self
        def get(type, id)
          case type
            when :biblio
             get_xml(BIBLIO_URL, id) 
            when :family
              get_xml(FAMILY_URL, id)
            when :family_biblio
              #get_xml(FAMILY_BIBLIO, id)
              get_xml(FAMILY_BIBLIO_EZ, id)
            when :family_biblio_doc
              get_xml(FAMILY_BIBLIO_DOC, id)
            when :fc
              get_xml(FC, make_ops_forward_cite_url(id))
          end
        end
  
        #
        # Find the referenced patent in the family biblio. The wrinkle here is that occasionally
        # a family is really long. The EPO seems to cut-off biblio information after the 100th family
        # member. So, check to see if the returned result is nil and if it is, fetch the straight biblio
        #
        def find_biblio
          biblio =  family.css('exchange-document').select {|x| x["doc-number"] == doc_number[2..-1]}
          if biblio.nil? || biblio[0].nil? 
            puts "Patent #{doc_number} family - biblio too long, fetching biblio"
            fetch(:biblio, doc_number)
          else
            biblio[0]
          end
        end
    
        def get_xml(url, doc_number)
      
          #print "Fetching #{doc_number}: #{url}\n"
          source = RestClient.post(url, doc_number)
          result = Nokogiri::HTML(source)

          rescue => e
            error = "for #{url} @ #{doc_number}\n ==> #{e.response}"
            case e.response.code
              when 403
                warn "-EPO Robot #{error}"
              when 413
                warn "-Ambiguous Response"
                warn "RE-LOAD value ===> #{url}"
                source = retry_ambiguous_response(e.response)
              when 503
                warn "EPO Server Timeout: #{error}"
              else
                warn "EPO Error: #{e.response.code} #{error}"
            end
            @error_state = true
            result
        end

        def retry_ambiguous_response response
          resp =  Nokogiri::HTML(response)
          resp.css("cause").text.match /Ambiguous/
          resolution = resp.css("resolution").last.text
          source = RestClient.get(FAMILY_ERROR + resolution)
        end

        def make_ops_forward_cite_url(doc_number)
          %w[ct ex op rf oc].map{|x| "#{x}%3D#{doc_number}"}.join(" or ")
        end
      end
    end
  end
end