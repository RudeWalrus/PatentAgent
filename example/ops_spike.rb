require "nokogiri"




def family(node)
  nodes.css("ops|family-member").each {|node|  e # !> shadowing outer local variable - node
    el   = node.css("publication-reference document-id").first
    cc   = el.css("country").text
    num  = el.css("doc-number").text
    kind = el.css("kind").text
    "#{cc}#{num}.#{kind}"
  }
end

def family_id(node)
  node.at_css('exchange-document')['family-id']
end

def patent_number(node)
   node.css('publication-reference document-id doc-number').first
end

def assignees(node)
  node.css('applicants applicant[@data-format="epodoc"] applicant-name name').map(&:text)
end

def inventors(node)
  node.css('inventors inventor[@data-format="epodoc"] inventor-name name').map {|el| el.text.strip.gsub(/\u2002/, '') }
end

def classification(node)
  node.css('patent-classifications patent-classification').map {|el|
    section = el.css("section").text
    _class = el.css("class").text
    subclass = el.css("subclass").text  # !> assigned but unused variable - subclass
    main_group = el.css("main-group").text
    subgroup = el.css("subgroup").text
    section + _class + main_group + subgroup
  }
end

def classification_ipcr(node)
  node.css("classification-ipcr text").map { |item|  item.text.delete(" ") }
end

def classification_national(node)
  node.css("classification-national text").map { |item|  item.text.delete(" ") }
end

def classification_ecla(node)
  node.css("classification-ecla classification-symbol").map { |item|  item.text.delete(" ") }
end

def title(node)
  node.css('invention-title[@lang="en"]').text
end

def abstract(node)
  node.css('abstract[@lang="en"] p').text
end

def issue_date(node)
  node.css('publication-reference document-id date').first
end

def application(node)
    item       = node.css('application-reference document-id').first
    doc_number = item.css('doc-number').text
    date       = item.css('date').text
    {date: date, doc_number: doc_number}
end

def priority(node)
    item       = node.css('priority-claims priority-claim document-id[@document-id-type="epodoc"]').last
    doc_number = item.css('doc-number').text
    date       = item.css('date').text
    {date: date, doc_number: doc_number}
end

def references(node)
  node.css('references-cited citation patcit document-id[@document-id-type="epodoc"] doc-number').map(&:text).sort 
end



file = File.read("8310121_family.xml") 
# look for some fields

nodes = Nokogiri::XML(file).css("ops|family-member")

nodes.each {|node|
  p family_id(node)
  p patent_number(node).text
  p issue_date(node).text
  p application(node)
  p inventors(node)
  p classification(node)
  p priority node
  p title node
  p references node
  p "****"
}