

module PatentAgent    
  class Patent
    
    attr_reader :doc_number, :claims,:epo, :pto
    
    def initialize(*patents)
      @epo = ::EPO::Patent.new(pnum)
      @pto = ::PTO::Patent.new(pnum)
    end
    
    def self.config(pnum, opts = {})
      yield self if block_given?
    end
  end
end
