module PatentAgent::OPS
  class Fields

    attr_reader :priority
    
    def initialize(node)
      node = node
      parse node
    end

    #
    # allows fields to be added
    def self.field(field,  &block)
      FIELDS[field] = block
      define_method(field) {instance_variable_get "@#{field}" }
    end

    FIELDS = {
      family_id:            ->(n) {n.at_css('exchange-document')['family-id']},
      patent_number:        ->(n) {n.css('publication-reference document-id [@document-id-type="epodoc"] doc-number').first.text},
      title:                ->(n) {n.css('invention-title[@lang="en"]').text},
      abstract:             ->(n) {n.css('abstract[@lang="en"] p').text},  
      assignees:            ->(n) {n.css('applicants applicant[@data-format="epodoc"] applicant-name name').map(&:text)},
      inventors:            ->(n) {n.css('inventors inventor[@data-format="epodoc"] inventor-name name').map {|el| el.text.strip } },
      #classification_ipcrs: ->(n) {n.css("classification-ipcr text").map { |el|  el.text.delete(" ") }},
      #classification_eclas: ->(n) {n.css("classification-ecla classification-symbol").map { |el|  el.text.delete(" ")} },
      #classification_nationals: ->(n) {n.css("classification-national text").map { |el|  el.text.delete(" ")} },
      classifications:      ->(n) {n.css('patent-classifications patent-classification').map { |el| to_classification(el)} },
      references:           ->(n) {n.css('references-cited citation patcit document-id[@document-id-type="epodoc"] doc-number').map(&:text).sort },
      issue_date:           ->(n) {n.css('publication-reference document-id date').first.text},
      file_date:            ->(n) {n.css('application-reference document-id date').first.text},
      priorities:           ->(n) {n.css('priority-claims priority-claim document-id[@document-id-type="epodoc"]').map { |el| to_doc_date(el)} },
      applications:         ->(n) {n.css('application-reference document-id[document-id-type="epodoc"]').map { |el| to_doc_date(el)} }
    }.each { |k, value| define_method(k) { instance_variable_get "@#{k}" }}

    #
    # class methods
    #

    # formatters for hashes
    def self.keys; FIELDS.keys; end
    
    def self.to_doc_date(el); { doc_number: el.css('doc-number').text, date: el.css('date').text }; end

    def self.to_classification(el)
      section    =   el.css("section").text
      _class     =   el.css("class").text
      subclass   =   el.css("subclass").text 
      main_group =   el.css("main-group").text
      subgroup   =   el.css("subgroup").text
      full = section + _class + subclass +  main_group + '/' + subgroup 
      {full: full, section: section, class: _class, subclass: subclass, main_group: main_group, subgroup: subgroup }
    end
    #
    # enumerators
    #
    def self.each(&blk); FIELDS.each() { |field, obj| yield field, obj }; end

    def self.count; FIELDS.size; end
  
    #
    # instance methods
    #

    def parse(node)
      FIELDS.each {|key,func|
        result = Array(func.call(node)).map { |x| x.respond_to?(:gsub) ? x.gsub(/\u2002/, '') : x }
        item = key.match(/s$/) ? result : result[0].to_s
        PatentAgent.dlog "OPSData", item
        instance_variable_set("@#{key}",item)
      }
      find_priority
    end

    def keys; FIELDS.keys; end

    def to_h
      hash = {}
      FIELDS.each { |field, search| hash[field] = instance_variable_get("@#{field.to_sym}")  }
      hash
    end

    # is this a issued patent
    def issued?
      PatentAgent::PatentNumber.valid_patent_number?(patent_number)
    end
    
    alias :to_hash :to_h
    private

    def find_priority
      dates  = priorities.map { |h| h[:date]}.min
      set_key :priority,   dates
    end
    
    def set_key( key, value )
      instance_variable_set("@#{key}",value)
    end

    def self.fmt_date(date)
      date.match /(\d{4})(\d{2})(\d{2})/
      {year: $1, month: $2, day: $3, full: date}
    end
  end
end