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
  end
end