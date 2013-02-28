require 'logger'

module PatentAgent
  
  class <<self
    attr_accessor :indent, :debug
    # Setup the logger.
    # Value should be a logger but can can be stdout, stderr, or a filename.
    # You can also configure logging by the environment variable PATENTAGENT_LOG.
    
    def logger
      @logger ||= create_log('patentagent.log')
    end
    
    def logger=(log_location)
      @logger = create_log(log_location)
    end

    def indent
      @indent ||= "\t\t"
    end

    #
    # a standard logging function that can print out
    # many kinds of objects from PatentAgent (Hashes, Arrays, etc)
    # Dumps data into whatever PatentAgent.logger points
    #
    def log(header = "no header", obj = nil, force = false)
      return nil unless (debug || force)
      msg = "#{header.to_s.upcase}:#{"="*5+">"}"
      case obj
        when Array
          msg += "Count: #{obj.size}\n"
          obj.each {|item| msg << "#{@indent}#{item}\n"}
        when Hash
          logger.info "Count: #{obj.size}\n"
          obj.each {|k,v| msg <<  "#{@indent}#{k}: #{v}\n"}
        when nil
          msg << "\n"
        else
          msg << "#{indent}#{obj}\n"
      end
      logger.info msg   
    end
    
    #
    # wrapper function that puts logging around a method and returns
    # the value of the method. It accepts a method name or optionally,
    # figures out from which method it was called from and uses that name.
    #  
    def with_logging(method_name = nil)
     method_name ||= caller[0][/`([^']*)'/, 1]
     result = yield
     self.log method_name, result
     result
    end

    private    
    # Create a log that respond to << like a logger
    # param can be 'stdout', 'stderr', a string (then we will log to that file)
    def create_log(param)
      case param.class.to_s
      when "String"
        case param
        when 'stdout'
           Logger.new(STDOUT)
        when'stderr'
           Logger.new(STDERR)
        else # create a file
           Logger.new(param)
        end
      when "StringIO"
          Logger.new(param)
      else
        name = ENV['PATENTAGENT_LOG'] || "patentagent.log"
        Logger.new(name)
      end
    end
  end
  
end