module PatentAgent::OPS
  class Fields

    # error raised when passed a bad patent number
    NoTextSource = Class.new(RuntimeError)

    attr_reader :application, :priority, :classification

    def initialize(node)
      @node = node
      #Nokogiri::XML(xml).css("ops|family-member")
    end


    FIELDS = {
      family_id:            ->(n) {n.at_css('exchange-document')['family-id']},
      patent_number:        ->(n) {n.css('publication-reference document-id [@document-id-type="epodoc"] doc-number').first.text},
      title:                ->(n) {n.css('invention-title[@lang="en"]').text},
      abstract:             ->(n) {n.css('abstract[@lang="en"] p').text},  
      assignees:            ->(n) {n.css('applicants applicant[@data-format="epodoc"] applicant-name name').map(&:text)},
      inventors:            ->(n) {n.css('inventors inventor[@data-format="epodoc"] inventor-name name').map {|el| el.text.strip } },
      classification_ipcrs: ->(n) {n.css("classification-ipcr text").map { |el|  el.text.delete(" ") }},
      classification_eclas: ->(n) {n.css("classification-ecla classification-symbol").map { |el|  el.text.delete(" ")} },
      classification_nationals: ->(n) {n.css("classification-national text").map { |el|  el.text.delete(" ")} },
      references:           ->(n) {n.css('references-cited citation patcit document-id[@document-id-type="epodoc"] doc-number').map(&:text).sort },
      issue_date:           ->(n) {n.css('publication-reference document-id date').first.text},
      priorities:           ->(n) {n.css('priority-claims priority-claim document-id[@document-id-type="epodoc"]').map { |el| Fields.to_doc_date(el)} },
      classifications:      ->(n) {n.css('patent-classifications patent-classification').map { |el| Fields.to_classification(el)} },
      applications:         ->(n) {n.css('application-reference document-id[document-id-type="epodoc"]').map { |el| Fields.to_doc_date(el)} }
    }.each { |k, value| define_method(k) { instance_variable_get "@#{k}" }}

    #
    # class methods
    #

    # formatters for hashes

    def self.to_doc_date(el); { doc_number: el.css('doc-number').text, date: el.css('date').text }; end

    def self.to_classification(el)
      {
      section:    el.css("section").text,
      class:      el.css("class").text,
      subclass:   el.css("subclass").text, 
      main_group: el.css("main-group").text,
      subgroup:   el.css("subgroup").text
      }
    end
    #
    # enumerators
    #
    def self.each(&blk); FIELDS.each() { |field, obj| yield field, obj }; end

    def self.count; FIELDS.size; end

    #
    # allows fields to be added
    def self.add(field,  &block)
      FIELDS[field] = block
      define_method(field) {instance_variable_get "@#{field}" }
    end

    #
    # instance methods
    #

    def process(node=@node)
      FIELDS.each {|key,func|
        result = Array(func.call(node)).map { |x| x.respond_to?(:gsub) ? x.gsub(/\u2002/, '') : x  }
        item = key.match(/s$/) ? result : result[0].to_s
        instance_variable_set("@#{key}",item)
        result
      }
      find_priority
    end

    def keys; FIELDS.map{|k,v| k}; end
    
    private


    def find_priority
      date  = priorities.map { |h| h[:date] }.min
      set_key :priority,   date
    end
    
    def set_key( key, value )
      instance_variable_set("@#{key}",value)
    end

  end
end