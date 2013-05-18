

module PatentAgent    
  class Patent
    
    attr_reader :inventors, :number, :priority_date
    
    def initialize(*patents)
      result = patents.each do |patent|
        patent = PatentAgent::PatentNum.new(patent) if patent.is_a?(String) 
        @number = patent
      end    
    end
    
    def self.config(pnum, opts = {})
      yield self if block_given?
    end

    def valid?
      @number && @number.valid?
    end

    def fetched?
      number && inventors && priority_date
    end
  end
end
