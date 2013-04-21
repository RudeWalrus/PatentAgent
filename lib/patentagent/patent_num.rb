module PatentAgent
  class PatentNum
    attr_reader  :country_code, :number, :kind, :full_number
    def initialize(pat_num)
       @patnum  = valid_patent_number? pat_num
       @valid = @patnum
    end 

    def valid?
      @valid
    end

    def get_country_code(num)
      num.match(/\A([a-zA-Z]{2})/) {|match|
         return "US" if match[1] == "RE"
         match[1]
      } || "US"
      
    end

    def get_kind(num)
      num.match(/\.([A-Z]\d\Z)/) {|match| match[1]} || ""
    end

    def get_number(num)
      num.match(/\A[A-Z]{2}?(\d{5,9})\.?([A-Z]\d)?\Z/) {|match| match[1]} || "error"
    end

    def check_for_country_code(number)
      #return "US" if number =~ /^RE\d{5}$}/ # US ReIssue 
      return number if number =~ /^[A-Z]{2}(\d+)/
      "US" + number
    end

    def valid_patent_number?(number)
      return nil if number.nil?
      #upcase, remove any commas
      patent = number.to_s.upcase.delete(",")
      patent = check_for_country_code(patent)
      @country_code  = get_country_code(patent)
      @kind          = get_kind(patent)
      @number        = get_number(patent)
      @full_number   = "#{@country_code}#{@number}"
      @full_number += ".#{@kind}" if @kind != ""
      
      return (patent =~ /^[A-Z]{2}(\d+)/) ? patent : nil
    end
    
    # formats the patent number to make it valid for HTML search
    #
    # accepts: US7,256,232.B1 or 7,256,232
    # returns: 7256232
    #
    def self.valid_us_patent_number?(num)
      num.to_s.
        delete("US").
        delete(',').
        match(/([45678]\d{6})(\.[AB][12])?$|([Rr][Ee]\d{5}$)/) {|match| match[1] || match[3]}
    end

    
  end
end