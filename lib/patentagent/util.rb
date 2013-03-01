module PatentAgent
  module Util
    
    def symbol_to_string(symbol)
      return symbol if symbol.is_a?(String)
      str = Array(symbol.to_s.split("_"))
      str.map(&:capitalize).join(" ")
    end 
  
    def to_symbol(name)
      name.to_s.downcase.gsub(" ", "_")
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