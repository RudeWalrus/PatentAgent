# The basic patent parser class
class PatentAgent::PTO::Patent
  include PatentAgent::Util
  include PatentAgent::Logging

  attr_reader :patent_number, :claims, :title, :abstract, :assignee, :app_number, :filed, :inventors, :text, :figures
  attr_reader :options, :html, :debug
  @fields = {}
  
  FIELDS    = {
    patent_number:   {gross: /<title>(.*?)<\/title>/mi,     fine: /[45678],?\d{3},?\d{3}|RE\d{5}/},
    title:           {gross: /<font size=\"\+1\">(.*?)<\/font>/mi, fine:  />(.*?)</mi},
    abstract:        {gross: /Abstract(.*?)<hr>/mi,         fine: /<p>(.*?)<\/p>/mi},
    assignee:        {gross: /Assignee:(.*?)<\/tr>/mi,      fine: /<b>(.*?)<\/b>\s*\((.*?)\),?/mi},
    app_number:      {gross: /Appl. No.:(.*?<b>.*?)<\/b>/mi,fine: /<b>(.*?)<\/b>/mi},
    filed:           {gross: /Filed:(.*?<b>.*?)<\/b>/mi,    fine: /<b>(.*?)<\/b>/mi},
    inventors:       {gross: /Inventors:(.*?)<\/tr>/mi,     fine: /<b>(.*?)<\/b>\s*\(.*?\)/mi, 
                        :filter => lambda { |x| x.delete(",").strip} },
    text:            {gross: /<HR> <CENTER>(.*?)\*\*<\/b>/mi,    fine: /Description(.*?)<\/b>/mi},
    figures:         {gross: /<BR><BR>BRIEF DESCRIPTION OF(.*?)<BR>DETAILED/mi, fine: /<BR><BR>(figs?\.?.*?)\.\n/mi}    
  }
  
  # error raised when passed a bad patent number
  class InvalidPatentNumber < RuntimeError; end
  
  def initialize(pnum, options = {})
    @patent_number = pnum
    setup_options(options)
    
    raise InvalidPatentNumber,"Invalid Patent #{pnum}" unless valid_patent_number?(pnum)
    
    rescue InvalidPatentNumber => e
       log "#{e}"
  end
  
  def setup_options(opts)
    @options ||= {:country =>"US", :debug => false, :fc => nil }
    @options.merge!(opts)
    @debug = @options[:debug]
  end
  
  def fetch
    @html = PatentAgent::PTO.get_html(patent_number)
    @claims = PatentAgent::Claims.new
    self
  end
  
  def self.fetch(pnum, options = {})
    patent = new(pnum, options)
  	patent.fetch
  end
    
  def parse
    parse_fields FIELDS
    parse_claims @html
    log "processed:", patent_number
    self  
  end

  def parse_fields(fields)
    fields.each do |field, search|
      val = parse_field(field, search)
      instance_variable_set("@#{field}",val)
    end
  end
  
  def parse_claims(text)
  	
    claim_text = text[/(?:Claims<\/b><\/i><\/center> <hr>)(.*?)(?:<hr>)/mi]

    raise "No Claims" if claim_text.nil?
  
    # lets get the individual claims. The parens in the regex force the results to
    # be placed into a capture group (an array within the array). The claim is element
    # 0 of this array
    m = claim_text.scan( /<br><br>\s*(\d+\..*?)((?=<br><br>\s*\d+\.)|(?=<hr>))/mi)

    raise "Malformed Claims" if m.nil?

    # collect the claims into an array
    m.each { |claim| @claims << claim[0].gsub("\n", " ").gsub(/<BR><BR>/, " ") }

    result = {count: claims.count, indep: claims.indep_count, dep: claims.dep_count, claims: claims }
    log "Claims:" , result
    
    rescue RuntimeError => e
      log "Error in claims parsing. #{e}"
      return ["Not found"]
  end

  #
  # Takes the main parsing routine for reading the PTO Files
  # It takes a gross search and a fine search and populates the array with the results
  # if a block is included, it runs the block on each of the matched search results (for the fine search)
  # 
  def parse_field(field, obj)
    
    gross = @html[obj[:gross]]
    
    log_field(field, gross)
    
    raise "Missing Field" if gross.nil?

    fine = gross.scan(obj[:fine])
    
    result = fine.map do |item|
      # check if the element is an array. If an array, it means that it contains 
      # a capture group and we'll need to use the first element.   
      val =  item.is_a?(Array) ? item[0] : item
      
      #strip those pesky newlines and convert tabs to spaces
      tmp = val.delete("\n").gsub(/\t/," ").squeeze(" ").strip
        
      #run whatever filter was passed in
      tmp = obj[:filter].call(tmp) unless obj[:filter].nil? 
      
      log_field(field.to_s, tmp)
      tmp	
    end
  
    log "#{PatentAgent.symbol_to_string(field)}", result
      
    result

    rescue => e
      ["Not Found: #{e}"]
  end
  
  def valid?
	 @patent_number && !!@html
	end
	
	def valid_html?
	  !!@html
	end
	
  private
  
  def log(msg, obj=nil, force = false)
    return unless @debug || force
    PatentAgent.log(msg, obj)
  end
  
  def log_field(field, message)
    log(field, message, true) if (@options[:dump] && @options[:dump].match(field.to_s))
  end
    
  def invalid_patent?
    !!@html[/No patents have matched your query/mi]
  end
    
end