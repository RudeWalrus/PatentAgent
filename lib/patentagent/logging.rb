require 'logger'

module PatentAgent
  module Logging
    extend self 

    def logger=(log_io, options = {})
      @logger = create_log(log_io)
    end

    def logger
      @logger ||= create_log('patentagent.log')
    end

    def indent
      @indent ||= "\t\t"
    end

    def debug
      @debug
    end

    def debug= value
      @debug = value
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
          msg += "Count: #{obj.size}\n"
          obj.each {|k,v| msg <<  "#{@indent}#{k}: #{v}\n"}
        when nil
          msg << "\n"
        else
          msg << "#{indent}#{obj}\n"
      end
      logger.info msg   
    end

    #
    # Setup the logger.
    # param can be stdout, stderr, a FileIO object, or a filename.
    # 
    def create_log(param="patentagent.log")
      if param.is_a?(String) then
        case param
          when 'stdout'
             Logger.new(STDOUT)
          when'stderr'
             Logger.new(STDERR)
          else # create a file
            Logger.new(param)
        end
      else
          Logger.new(param)
      end
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

    # module ClassMethods
    #   #attr_accessor :indent, :debug
    # end

    # def self.included(base)
    #   base.extend(ClassMethods)
    # end
  end
end