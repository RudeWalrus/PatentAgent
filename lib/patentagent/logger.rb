module PatentAgent
  
  class << self

    # Setup the logger.
    # Value should be a logger but can can be stdout, stderr, or a filename.
    # You can also configure logging by the environment variable PATENTAGENT_LOG.
    def logger=(log)
      @logger = create_log log
    end

    def logger # :nodoc:
      @logger ||= create_log
    end

    #
    # a standard logging function that can print out
    # many kinds of objects from PatentAgent (Hashes, Arrays, etc)
    # Dumps data into whatever PatentAgent.logger points
    #
    def log(header = "no header", obj = nil)
      logger.info "\t#{header.to_s.upcase}:#{"="*5+">"}"
      indent = "\t\t"
      case obj
        when Array
          logger.info "Count: #{obj.size}\n"
          obj.each {|item| logger.info "#{indent}#{item}\n"}
        when Hash
          logger.info "Count: #{obj.size}\n"
          obj.map {|k,v| logger.info << "#{indent}#{k}: #{v}\n"}
        when nil
          logger.info "\n"
        else
          logger.info "#{indent}#{obj}\n"
      end   
    end

    private
    # Create a log that respond to << like a logger
    # param can be 'stdout', 'stderr', a string (then we will log to that file) or a logger (then we return it)
    def create_log(param='stdout')
      if param.is_a? String
        case param
        when 'stdout'
         logger = Logger.new(STDOUT)
        when'stderr'
          logger = Logger.new(STDERR)
        else
          logger Logger.new(param)
        end
      else
        name = ENV['PATENTAGENT_LOG'] || "patentagent.log"
        logger = Logger.new(name)
      end
    end
  end
  
end