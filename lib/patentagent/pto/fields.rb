# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3


module PatentAgent
  module PTO
    class Fields

      include Logging

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
        text:            {gross: /<B><I> Description(.*?)\* \*<\/b>/mi, fine: /Description(.*?)\* \*/mi},
        parent_case:     {gross: /Parent Case Text(.*?)<CENTER>/mi,     fine: /<hr>(.*?)<\/hr>/mi},
        figures:         {gross: /<BR><BR>BRIEF DESCRIPTION OF(.*?)<BR>DETAILED/mi, fine: /<BR><BR>(figs?\.?.*?)\.\n/mi}    
      }.each { |m, value| define_method(m) { instance_variable_get "@#{m}" }}

      #
      # class methods
      #
      def self.each(&blk)
        FIELDS.each() { |field, obj| yield field, obj }
      end

      def self.count
        FIELDS.size
      end

      #
      # allows a user to add fields to the search
      def self.add(field, gross, fine, &block)
        FIELDS[field] = {gross: gross, fine: fine, filter: block}
        define_method(field) {instance_variable_get "@#{field}" }
      end

      #
      # instance methods
      #

      # error raised when passed a bad patent number
      NoTextSource = Class.new(RuntimeError)

      attr_reader :html

      def initialize(html=nil)
        @html = html
      end


      def set_src(text)
        @html = text
        return self
      end

      def valid?
        !!@html
      end

      #
      # parses all of the fields
      # @returns: self (can be chained)
      def parse
        raise NoTextSource, "No HTML source for Fields" if !valid?

        FIELDS.each do |field, search|
          parse_single_field(field, search)
        end
        self
      end

      #
      # convenience method to parse a single field by key
      # @returns: self
      def parse_field(field)
        hash = FIELDS[field]
        parse_single_field(field, hash)
      end

      def to_hash
        hash = {}
        Fields.each { |field, search| hash[field] = instance_variable_get("@#{field.to_sym}") }
        hash
      end
    
      private
      #
      # The main parsing routine for reading the PTO Files
      # It takes a gross search and a fine search and populates the array with the results
      # if a proc is included, it runs the proc on each of the matched search results (for the fine search)
      # 
      def parse_single_field(field, params) 
        # run the gross filter which leaves us with a subtring
        gross = @html[params[:gross]]
        raise "Missing Field" if gross.nil?
        
        log_field(field, gross)
        
        # run the fine search
        fine = gross.scan(params[:fine])
        
        result = fine.map do |item|
          # check if the element is an array. If an array, it means that it contains 
          # a capture group and we'll need to use the first element.   
          val =  item.is_a?(Array) ? item[0] : item
          
          #strip those pesky newlines and convert tabs to spaces
          tmp = val.delete("\n").gsub(/\t/," ").squeeze(" ").strip
            
          #run whatever filter was passed in
          tmp = params[:filter].call(tmp) unless params[:filter].nil? 
          tmp
        end

        log field, result

        # if the name ends in s, store as an array, otherwise
        # convert to a string (first element of array) 
        item = field.match(/s$/) ? result : result[0].to_s
        instance_variable_set("@#{field}",item)
        item

        rescue => e
          ["Field parse error: Not Found: #{field} #{params[:gross]} #{@html}"]
      end
        
      def log_field(field, message)
        log(field, message, true) #if field_enabled
      end

      def field_enabled(field)
        (@options[:dump] && @options[:dump].match(field.to_s))
      end
    end
  end
end