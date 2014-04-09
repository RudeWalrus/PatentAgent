require "patentagent/util"
require "patentagent/logging"
require "patentagent/client"
require "patentagent/us/urls"


module PatentAgent
  module USPTO
    class Fields
      include Util
      include Logging

      attr_reader :patent, :html

      # TODO: add these fields
      # :ipc_codes, :back_citations, :fwd_citations, :pct
      
      # 
      # create the fields and define getter methods for them
      #
      # Fields includes the field name, a gross filter search, a fine filter search and an optional filter proc
      #
      FIELDS    = {
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
      }.each { |m, value| define_method(m) { instance_variable_get "@#{m}" } }

      def initialize(patent)
        @patent = patent.patent_num
        @html   = patent.html
      end

      def parse
        FIELDS.each do |field, search|
          val = parse_field(field, search)
          instance_variable_set("@#{field}",val)
        end
        self
      end

      private
      #
      # The main parsing routine for reading the PTO Files
      # It takes a gross search and a fine search and populates the array with the results
      # if a proc is included, it runs the proc on each of the matched search results (for the fine search)
      # 
      def parse_field(field, params)
        
        # run the gross filter
        gross = @html[params[:gross]]

        raise "Missing Field" if gross.nil?
        
        log_field(field, gross)
        
        # run the fine search
        fine = gross.scan(params[:fine])
        
        result = fine.map { |item|
          # check if the element is an array. If an array, it means that it contains 
          # a capture group and we'll need to use the first element.   
          val =  item.is_a?(Array) ? item[0] : item
          
          #strip those pesky newlines and convert tabs to spaces
          tmp = val.delete("\n").gsub(/\t/," ").squeeze(" ").strip
            
          #run whatever filter was passed in
          tmp = params[:filter].call(tmp) unless params[:filter].nil? 
          
          log_field(field.to_s, tmp)
          tmp 
        }
      
        log "#{symbol_to_string(field)}", result
          
        result

        rescue => e
          ["Not Found: #{e}"]
      end

      def log_field(field, message)
        log(field, message, true) #if (@options[:dump] && @options[:dump].match(field.to_s))
      end
    end
  end
end