module PatentAgent
  class PatentNum
    attr_reader  :country_code, :number, :kind
    
    def initialize(pat_num)
      @clean                          = cleanup_number pat_num
      @country_code, @number, @kind   = valid_patent_number?(@clean) 
    end 
    
    #  
    # assumes the number has been cleaned (all upcase, no commas, etc)
    #
    # returns a array where:
    #       =>  cc is country
    #       =>  number is number. 5 to 9 digits. Checked against US valid numbers too
    #       =>  kind is kind. This is something like A1 or B2
    #
    def valid_patent_number?(num)
      if num =~ /\A([A-Z]{2})?(\d{5,9})\.?([A-Z]\d)?\Z/ then
        cc      = get_country_code($1)
        number  = $2
        kind    = $3 || ""  # if nil, set it to a blank
        
        # extra case to check for US ReIssue
        if cc == "US" then
          valid_us = valid_us_patent_number? num 
        else
          valid_us = true
        end
        
        @valid = (cc && number && valid_us) ? true : false
        [cc,number,kind]
      else
        @valid = false
        nil
      end
    end
    
    # formats the patent number to make it valid for HTML search
    #
    # accepts: US7,256,232.B1 or 7,256,232
    # returns: 7256232
    #
    def valid_us_patent_number?(num)
      num.match(/(US)?([45678]\d{6})(\.[AB][12])?$|(RE\d{5}$)/) {|match| match[2] || match[4]}
    end

    #
    # Returns the cleaned version of the input
    #
    def to_s
      return nil unless valid?
      @clean
    end

    def valid?
      @valid
    end


    private
    #
    # A two letter country code like US, CA, JP, etc. Special case is RE,
    # which is a US re-issued patent. If RE, then its US.
    #
    def get_country_code(num)
      return "US" if num.nil?
      num.match(/([A-Z]{2})/) {|m| m[1] == "RE" ? "US" : m[1]} || "US"
    end
    
    # 
    # cleans up the passed in string
    def cleanup_number(number)
      return nil if number.nil?
      #upcase, remove any commas
      patent = number.to_s.upcase.delete(",").delete(" ")
    end

  end

end