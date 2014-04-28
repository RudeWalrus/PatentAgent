require 'nokogiri'
require 'set'
require 'json'
# 
# from the EPO.org website
#
# For using EPODOC format
#epodoc
#   => Input consists of 3 possible parts:
#   -  number (the epodoc number string) - mandatory
#   -  kind code (KC) - optional docdb kind code
#   -  date (date) - optional 
#
# => Note, the date format used in OPS is ALWAYS YYYYMMDD.
#

module PatentAgent
  module OPS  
    class OpsPatent
      include PatentAgent
      include Logging
      
      attr_accessor  :patent_num, :error_state, :family_members, :target
      
      def initialize(pnum, options = {})   
        # setup options first with defaults
        setup_options options
        @patent_num = PatentNumber(pnum)
        
        raise "Invalid Patent Number" unless @patent_num.valid?

        # returns a Nokogiri document
        @family_members = []
        @nodes = Reader.get_family(@patent_num)
        @fields = parse 
        
        # the publicly viewable methods
        @target = @fields[0].to_hash
      end

      #
      # iterate through teh family members and parse them. 
      # @Returns: Array of family members (each is a Hash)
      def parse
        @nodes.css("ops|family-member").map {|node|
          add_family_member(node)
          item = OPSFields.new(node)
        } 
      end
      
      #
      # @returns: Array. All of the parsed data. Each element of the the array is a family member.
      #                   element 0 is the base patent
      def to_a
        @fields.map(&:to_hash) || []
      end
      #
      # delegate calls for the fields to the OPSFields object
      # the primary patent is the first one in the array
      #
      def method_missing(method, *args)
        return @fields[0].send(method) if @fields[0].respond_to?(method)
        super
      end

      def respond_to_missing?(method, include_private = false)
        @family[0].respond_to?(method) || super
      end

      def add_family_member(node)
          el   = node.css("publication-reference document-id").first
          cc   = el.css("country").text
          num  = el.css("doc-number").text
          kind = el.css("kind").text
          @family_members << "#{cc}#{num}.#{kind}"
      end

      def cache; @cache ||= {};  end

      def family; to_a || []; end
      
      def valid?; @ops_data; end

      def invalid?; @error_state; end
      
      def setup_options(options)
        @options ||= {
          country: "US",
          debug: false,
          fc: nil,
          auth: false,
          error_state: false
        }
        @options.merge!(options)
      end
      def forward_citations
        fc.css("document-id").map do |item|
          country = item.css("country").text
          doc_num = item.css("doc-number").text
          kind    = item.css("kind").text
          "#{country}.#{doc_num}.#{kind}"
        end
      end
    
      #
      # grabs the forward-sited references for doc_number
      #
      def fetch_fc
        families  = Hash.new{|h, k| h[k] = []}
        citations = Set.new

        #for each reference get a family-id (we'll group these later)
        fc.css("publication-reference").each do |ref|
          family = ref["family-id"]
          # look at each reference's kind
          ref.css('document-id[@document-id-type="docdb"]').each do |item|

            data = PublicationData.from_xml(item)

            #check if its published
            if data[:published]
              print "#FC Patent:", "#{data[:full]} => Family-id: #{family} "
              citations << data
            else
              print "#FC App: #{data[:full]} => Family-id: #{family} - "
              unless families.key?(family)
                patents = search_for_reference(data[:full], doc_number)
                citations.merge(patents)
                puts "Converts to :#{patents.map{|x| x[:full]}.join(" ")}"
              else
                puts "Skipping, already in family"
              end
            end
            #add to the family
            #puts "Adding #{data[:number]} to #{family}"
            families[family] << data
          end
        end
        citations.to_a
        #    puts "FC families result:"
        #    families.each do |k, v| 
        #      print "#{k} :"
        #      puts v.map{ |dat| dat[:id]}.join(" ")
        #    end
        #
        #    puts "Unique US FCs: #{citations.size}"
        #    citations.select{|x| x[:id] =~ /^US/}.each{|v| puts "\t#{v[:id]}"}
        #    #@bc.inspect
      end

      #
      # This method converts an application number to its patent number. It does this
      # by searching for citations (this is a forward citation for the target) 
      # Input: 
      #         docdb_number is the app number in docdb format
      #         target is the reference patent (the patent cited as prior art)
      # It searches the family biblio for the target patent. The target will be a citation
      # in the issuance chain. When we find a citation we go up the chain to the root and 
      # see if there is a B1 publication (i.e. an issued patent) 
      #
      def search_for_reference(docdb_number, target)
        members = []
        xml = Reader.get :family_biblio_doc, docdb_number
        xml.search("[text()*=#{target}]").each do |item|
          data = item.ancestors("family-member").css('publication-reference document-id[@document-id-type="docdb"]').first
          pub_data = PublicationData.from_xml(data) 
          #puts "Found #{pub_data[:id]}"
          members << pub_data if pub_data[:published]     
        end
        members
      end 

      # def process
      #   return nil if error_state
        
        
      #   family = Family.from_xml(@family)
      #   log "Family", family.families
        
      #   _fc = ForwardCitation.from_xml(@fc)
      #   log "Forward Citations", _fc.citations
        
      #   tree = fetch_fc
      #   log "Normalized Forward Citations", tree
      #   print "Processed (#{@patent_number}\n)"
      # end
    end
    
    class ForwardCitation
      attr_reader :citations
      
      def initialize(citations_array)
        @citations = citations_array
      end
      def count
        @citations.size
      end
      def self.from_xml(xml)
        citations = xml.css("document-id").map {|item| PublicationData.from_xml(item) }
        new(citations)
      end
    end
    
    class Family < Array
      attr_reader :families
    
      def initialize(family_array)
        family_array.each{|x| self << x}
      end
      def count
        @families.size
      end
      def self.from_xml(xml)
        new  xml.css('family-member > publication-reference document-id[@document-id-type="docdb"]').map { |item| PublicationData.from_xml(item) }
      end
    end
    
    class PublicationData
      attr_reader :full, :number, :country, :kind, :date, :published
      def initialize(attribs)
        @number     = attribs[:number]
        @country    = attribs[:country]
        @kind       = attribs[:kind]
        @date       = attribs[:date]
        @published  = attribs[:published]
        @full       = attribs[:full]
      end
      
      def self.from_xml(xml)
        id        = xml.css("doc-number").text
        kind      = xml.css("kind").text
        country   = xml.css("country").text
        published = PatentNumber.is_published?(id, kind, country)
        date      = OPS.to_patent_date(xml.css("date").text)
        full      = "#{country}.#{id}.#{kind}"
        {full: full, number: id, country: country, kind: kind, date: date, published: published}
      end
    end 

    #
    # convert patent date to a Time object
    #
    def self.to_patent_date(text)
      /(\d{4})(\d{2})(\d{2})/.match(text.to_s)
      Time.utc($1, $2, $3) unless $1.nil?
    end

    # create a proc version of the above to pass to map, each, etc.
    def self.pub_data 
      method(:get_publication_data).to_proc
    end
    #
    # generic routine to create a publication data Hash
    #
    def self.get_publication_data(el)
      country   = el.css("country").text
      id        = el.css("doc-number").text
      kind      = el.css("kind").text
      full      = "#{country}.#{id}.#{kind}"
      date      =  el.css("date").text
      published = !!(kind[0] =~ /^B/)
      { full: id, date: date, country: country, number: id, kind: kind, published: published}
    end
  end
end
