module PatentAgent::OPS
  class Fields
    FIELDS = {
      family_id:            ->(n) {n.at_css('exchange-document')['family-id']},
      patent_number:        ->(n) {n.css('publication-reference document-id doc-number').first.text},
      title:                ->(n) {n.css('invention-title[@lang="en"]').text},
      abstract:             ->(n) {n.css('abstract[@lang="en"] p').text},  
      assignees:            ->(n) {n.css('applicants applicant[@data-format="epodoc"] applicant-name name').map(&:text)},
      inventors:            ->(n) {n.css('inventors inventor[@data-format="epodoc"] inventor-name name').map {|el| el.text.strip } },
      classification_ipcrs:  ->(n) {n.css("classification-ipcr text").map { |el|  el.text.delete(" ") }},
      classification_eclas:  ->(n) {n.css("classification-ecla classification-symbol").map { |el|  el.text.delete(" ")} },
      classification_nationals: ->(n) {n.css("classification-national text").map { |el|  el.text.delete(" ")} },
      references:           ->(n) {n.css('references-cited citation patcit document-id[@document-id-type="epodoc"] doc-number').map(&:text).sort },
      issue_date:           ->(n) {n.css('publication-reference document-id date').first.text}
    }.each { |k, value| define_method(k) { instance_variable_get "@#{k}" }}

    #
    # class methods
    #
    def self.each(&blk); FIELDS.each() { |field, obj| yield field, obj }; end

    def self.count; FIELDS.size; end

    #
    # allows a user to add fields to the search
    def self.add(field,  &block)
      FIELDS[field] = block
      define_method(field) {instance_variable_get "@#{field}" }
    end

    #
    # instance methods
    #

    # error raised when passed a bad patent number
    NoTextSource = Class.new(RuntimeError)

    attr_reader :xml, :application, :priority, :classification

    def initialize(xml=nil)
      @nodes = Nokogiri::XML(xml).css("ops|family-member")
    end

    def process
      @nodes.each {|node|
        result = FIELDS.map {|key,func|
          result = Array(func.call(node)).map {|x| x.gsub(/\u2002/, '')}
          item = key.match(/s$/) ? result : result[0].to_s
          instance_variable_set("@#{key}",item)
        }
        get_classification node
        get_application node
        get_priority node
      }
    end

    def keys; FIELDS.map{|k,v| k}; end
    private

    def get_classification node
      codes = node.css('patent-classifications patent-classification').map {|el|
        section = el.css("section").text
        _class = el.css("class").text
        subclass = el.css("subclass").text 
        main_group = el.css("main-group").text
        subgroup = el.css("subgroup").text
        (section + _class + subclass + main_group + subgroup)
      }
      # set the result but trip out any empty ("") entries
      set_key :classification, codes.reject(&:empty?)
    end

    def get_application node
        el = node.css('application-reference document-id[document-id-type="epodoc"]').first
        set_key :application, {doc_number: el.css('doc-number').text, date: el.css('date').text}
    end

    def get_priority node
      res = {} 
      els = node.css('priority-claims priority-claim document-id[@document-id-type="epodoc"]')
      _date = els.map do |el|
        doc_number  = el.css('doc-number').text
        date        = el.css('date').text
        res[date]   = doc_number
        date.to_i
      end.min
      set_key :priority,  { doc_number: res[_date.to_s], date: _date.to_s,}
    end
    
    def set_key( key, value )
      instance_variable_set("@#{key}",value)
    end

  end
end