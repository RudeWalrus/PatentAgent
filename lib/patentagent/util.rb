module PatentAgent
  module Util
    
    def log(header, obj=nil, force=false)
      PatentAgent.log(header, obj, force)
    end
    #
    # wrapper function that puts logging around a method and returns
    # the value of the method. It accepts a method name or optionally,
    # figures out from which method it was called from and uses that name.
    #  
    def with_logging(method_name = nil)
  	 method_name ||= caller[0][/`([^']*)'/, 1]
     result = yield
     PatentAgent.log method_name, result
     result
  	end
  	
    def valid_patent_number?(number)
      return nil if number.nil?
      #upcase, kill off any trailing publication string (i.e. .B1) and remove any periods or spaces
      patent = number.to_s.upcase.gsub(/\.[A-Z]\d$/,"").delete(".")
      patent = check_for_country_code(patent)
      return (patent =~ /^[A-Z]{2}(\d+)/) ? patent : nil
    end
  
    def check_for_country_code(number)
  	  return number if number =~ /^[a-zA-Z]{2}(\d+)/
  	  "US" + number
  	end
  end
end