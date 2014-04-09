class Fields
  FIELDS = {
      patent_number:   {gross: /<title>(.*?)<\/title>/mi,             fine: /[45678],?\d{3},?\d{3}|RE\d{5}/},
      title:           {gross: /<font size=\"\+1\">(.*?)<\/font>/mi,  fine:  />(.*?)</mi},
      abstract:        {gross: /Abstract(.*?)<hr>/mi,                 fine: /<p>(.*?)<\/p>/mi},
      assignees:       {gross: /Assignee:(.*?)<\/tr>/mi,              fine: /<b>(.*?)<\/b>\s*\((.*?)\),?/mi},
      app_number:      {gross: /Appl. No.:(.*?<b>.*?)<\/b>/mi,        fine: /<b>(.*?)<\/b>/mi},
      filed:           {gross: /Filed:(.*?<b>.*?)<\/b>/mi,            fine: /<b>(.*?)<\/b>/mi},
      inventors:       {gross: /Inventors:(.*?)<\/tr>/mi,             fine: /<b>(.*?)<\/b>\s*\(.*?\)/mi, 
                          :filter => ->(x) { x.delete(",").strip} },
      text:            {gross: /<HR> <CENTER>(.*?)\*\*<\/b>/mi,       fine: /Description(.*?)<\/b>/mi},
      parent_case:     {gross: /Parent Case Text(.*?)<CENTER>/mi,     fine: /<hr>(.*?)<\/hr>/mi},
      figures:         {gross: /<BR><BR>BRIEF DESCRIPTION OF(.*?)<BR>DETAILED/mi, fine: /<BR><BR>(figs?\.?.*?)\.\n/mi}    
  }.each do |m, value|
    define_method("#{m}=") { |value| instance_variable_set("@#{m}", value) }
    define_method(m) { instance_variable_get "@#{m}" }
  end
  
  def initialize()
  end
end

class Example
  attr_reader :fields
  def initialize(one, two)
    @fields = Fields.new
    @fields.title =one
    @fields.text = two
  end
  def method_missing(method, *args)
    return @fields.send(method) if @fields.respond_to?(method)
    super
  end
end

test1 = Example.new(1, 2)
test2 = Example.new(3, 4)
