require "nokogiri"

class Ops
  
  def initialize(file)
    file = File.read(file)
  
    # look for some fields
    @nodes = Nokogiri::XML(file).css("ops|family-member")
  end

  def process
    @nodes.each {|node|
      result = FUNCS.map {|key,func|  # !> assigned but unused variable - result
        print "#{key}: ==>"
        p Array(func.call(node)).map { |x| x.respond_to?(:gsub) ? x.gsub(/\u2002/, '') : x  }
      }
      
      puts "*********"
    }
  end

  def to_patent_date(text)
      /(\d{4})(\d{2})(\d{2})/.match(text.to_s)
      Time.utc($1, $2, $3) unless $1.nil?
  end

  def family
    @nodes.css("ops|family-member").each {|node|
      el   = node.css("publication-reference document-id").first
      cc   = el.css("country").text
      num  = el.css("doc-number").text
      kind = el.css("kind").text
      p "#{cc}#{num}.#{kind}"
    }
  end
  
  FUNCS = {
    family_id:            ->(n) {n.at_css('exchange-document')['family-id']},
    patent_number:        ->(n) {n.css('publication-reference document-id [@document-id-type="epodoc"] doc-number').first.text},
    assignees:            ->(n) {n.css('applicants applicant[@data-format="epodoc"] applicant-name name').map(&:text)},
    inventors:            ->(n) {n.css('inventors inventor[@data-format="epodoc"] inventor-name name').map {|el| el.text.strip } },
    classification_ipcr:  ->(n) {n.css("classification-ipcr text").map { |el|  el.text.delete(" ") }},
    references:           ->(n) {n.css('references-cited citation patcit document-id[@document-id-type="epodoc"] doc-number').map(&:text).sort },
    classification_national: ->(n) {n.css("classification-national text").map { |el|  el.text.delete(" ")} },
    classification_ecla:  ->(n) {n.css("classification-ecla classification-symbol").map { |el|  el.text.delete(" ")} },
    title:                ->(n) {n.css('invention-title[@lang="en"]').text}, 
    abstract:             ->(n) {n.css('abstract[@lang="en"] p').text}, 
    issue_date:           ->(n) {n.css('publication-reference document-id date').first.text},
    priorities:     ->(n) {n.css('priority-claims priority-claim document-id[@document-id-type="epodoc"]').map { |el| Ops.to_doc_date(el)} },
    classifications:     ->(n) {n.css('patent-classifications patent-classification').map { |el| Ops.to_classification(el)} },
    applications:  ->(n) {n.css('application-reference document-id[document-id-type="epodoc"]').map { |el| Ops.to_doc_date(el)} }
  }

  def self.to_doc_date(el)
    { doc_number: el.css('doc-number').text, date: el.css('date').text }
  end

  def self.to_classification el
      section    =   el.css("section").text
      _class     =   el.css("class").text
      subclass   =   el.css("subclass").text 
      main_group =   el.css("main-group").text
      subgroup   =   el.css("subgroup").text
      full = section + _class + subclass +  main_group + '/' + subgroup 
      {full: full, section: section, class: _class, subclass: subclass, main_group: main_group, subgroup: subgroup }
  end

  def priority_date node
    res = {} 
    els = node.css('priority-claims priority-claim document-id[@document-id-type="epodoc"]')
    _date = els.map do |el|
      doc_number  = el.css('doc-number').text
      date        = el.css('date').text
      res[date]   = doc_number
      date.to_i
    end.min
    {date: _date.to_s, doc_number: res[_date.to_s]}
  end

  def get_priority
    priorities = @nodes.each {|node|
      priorities = FUNCS[:priorities].call(node)
      date  = priorities.map { |h| h[:date] }.min
      p ":priority #{date}"
    }
  end

  

  def exec(name)
    key  = name.to_sym
    @nodes.each {|node| 
      p FUNCS[key].call node
      puts "*****"
    }
  end
end 


data = Ops.new("family.xml")
p data.exec "classifications" 
# >> [{:full=>"H04L47/621", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"621"}, {:full=>"H04L12/5601", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5601"}, {:full=>"H04L12/5602", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5602"}, {:full=>"H04L12/5693", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5693"}, {:full=>"H04L47/22", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"22"}, {:full=>"H04L47/2441", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"2441"}, {:full=>"H04L47/35", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"35"}, {:full=>"H04L49/90", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"49", :subgroup=>"90"}, {:full=>"H04L49/9094", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"49", :subgroup=>"9094"}, {:full=>"H04L2012/5652", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5652"}, {:full=>"H04L2012/5658", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5658"}, {:full=>"H04L2012/5667", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5667"}, {:full=>"H04L2012/5669", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5669"}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}]
# >> *****
# >> [{:full=>"H04L12/5693", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5693"}, {:full=>"H04L47/22", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"22"}, {:full=>"H04L47/2425", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"2425"}, {:full=>"H04L47/2441", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"2441"}, {:full=>"H04L2012/5652", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5652"}, {:full=>"H04L2012/5667", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5667"}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}]
# >> *****
# >> [{:full=>"H04L47/621", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"621"}, {:full=>"H04L12/5601", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5601"}, {:full=>"H04L12/5602", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5602"}, {:full=>"H04L12/5693", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5693"}, {:full=>"H04L47/22", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"22"}, {:full=>"H04L47/2441", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"2441"}, {:full=>"H04L47/35", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"35"}, {:full=>"H04L49/90", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"49", :subgroup=>"90"}, {:full=>"H04L49/9094", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"49", :subgroup=>"9094"}, {:full=>"H04L2012/5652", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5652"}, {:full=>"H04L2012/5658", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5658"}, {:full=>"H04L2012/5667", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5667"}, {:full=>"H04L2012/5669", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5669"}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}]
# >> *****
# >> [{:full=>"H04L47/621", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"621"}, {:full=>"H04L12/5601", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5601"}, {:full=>"H04L12/5602", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5602"}, {:full=>"H04L12/5693", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5693"}, {:full=>"H04L47/22", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"22"}, {:full=>"H04L47/2441", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"2441"}, {:full=>"H04L47/35", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"35"}, {:full=>"H04L49/90", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"49", :subgroup=>"90"}, {:full=>"H04L49/9094", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"49", :subgroup=>"9094"}, {:full=>"H04L2012/5652", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5652"}, {:full=>"H04L2012/5658", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5658"}, {:full=>"H04L2012/5667", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5667"}, {:full=>"H04L2012/5669", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5669"}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}]
# >> *****
# >> [{:full=>"H04L47/621", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"621"}, {:full=>"H04L12/5601", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5601"}, {:full=>"H04L12/5602", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5602"}, {:full=>"H04L12/5693", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5693"}, {:full=>"H04L47/22", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"22"}, {:full=>"H04L47/2441", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"2441"}, {:full=>"H04L47/35", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"35"}, {:full=>"H04L49/90", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"49", :subgroup=>"90"}, {:full=>"H04L49/9094", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"49", :subgroup=>"9094"}, {:full=>"H04L2012/5652", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5652"}, {:full=>"H04L2012/5658", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5658"}, {:full=>"H04L2012/5667", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5667"}, {:full=>"H04L2012/5669", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5669"}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}]
# >> *****
# >> [{:full=>"H04L49/602", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"49", :subgroup=>"602"}, {:full=>"H04L49/30", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"49", :subgroup=>"30"}, {:full=>"H04L2012/5605", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5605"}, {:full=>"H04L2012/5652", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5652"}, {:full=>"H04L2012/5667", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5667"}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}]
# >> *****
# >> [{:full=>"H04L49/602", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"49", :subgroup=>"602"}, {:full=>"H04L49/30", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"49", :subgroup=>"30"}, {:full=>"H04L2012/5605", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5605"}, {:full=>"H04L2012/5652", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5652"}, {:full=>"H04L2012/5667", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5667"}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}]
# >> *****
# >> [{:full=>"H04L47/621", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"621"}, {:full=>"H04L12/5601", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5601"}, {:full=>"H04L12/5602", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5602"}, {:full=>"H04L12/5693", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5693"}, {:full=>"H04L47/22", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"22"}, {:full=>"H04L47/2441", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"2441"}, {:full=>"H04L47/35", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"35"}, {:full=>"H04L49/90", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"49", :subgroup=>"90"}, {:full=>"H04L49/9094", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"49", :subgroup=>"9094"}, {:full=>"H04L2012/5652", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5652"}, {:full=>"H04L2012/5658", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5658"}, {:full=>"H04L2012/5667", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5667"}, {:full=>"H04L2012/5669", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5669"}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}]
# >> *****
# >> [{:full=>"H04L47/621", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"621"}, {:full=>"H04L12/5601", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5601"}, {:full=>"H04L12/5602", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5602"}, {:full=>"H04L12/5693", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"12", :subgroup=>"5693"}, {:full=>"H04L47/22", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"22"}, {:full=>"H04L47/2441", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"2441"}, {:full=>"H04L47/35", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"47", :subgroup=>"35"}, {:full=>"H04L49/90", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"49", :subgroup=>"90"}, {:full=>"H04L49/9094", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"49", :subgroup=>"9094"}, {:full=>"H04L2012/5652", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5652"}, {:full=>"H04L2012/5658", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5658"}, {:full=>"H04L2012/5667", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5667"}, {:full=>"H04L2012/5669", :section=>"H", :class=>"04", :subclass=>"L", :main_group=>"2012", :subgroup=>"5669"}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}, {:full=>"/", :section=>"", :class=>"", :subclass=>"", :main_group=>"", :subgroup=>""}]
# >> *****
# >> 0