require 'patentagent'

module PatentAgent
  class Dispatcher
    
    attr_reader :list, :results
    def initialize(*patents)
      @list    = Array(patents).flatten
      @results = []
    end
  end
end