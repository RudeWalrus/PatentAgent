# Author::    Michael Sobelman  (mailto:boss@rudewalrus.com)
# Copyright:: Copyright (c) 2014 RudeWalrus
# License::   Creative Commons 3

module PatentAgent
  module Logging
    
    def logger
      @logger ||= initialize_log
    end

    def logger=(log)
      @logger = initialize_log(log)
    end

    # a standard logging function that can print out
    # many kinds of objects from PatentAgent (Hashes, Arrays, etc)
    # Dumps data into whatever PatentAgent.logger points
    #
    def log(header = "no header", obj = nil)
      msg = fmt_log(header, obj)
      PatentAgent.logger.info msg
      obj  
    end

    def dlog(header = "no header", obj = nil)
      msg = fmt_log(header, obj)
      PatentAgent.logger.debug msg
      obj
    end

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
    #
    # Setup the logger.
    # param can be stdout, stderr, a FileIO object, or a filename.
    # 
    def initialize_log(log_target = STDOUT)
      oldlogger ||= nil
      @logger = Logger.new(log_target)
      @logger.level = Logger::INFO
      oldlogger.close if oldlogger && !$TESTING # don't want to close testing's STDOUT logging
      @logger
    end
    
    # formatting
    def fmt_log(header, obj)
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
      msg  
    end

    def indent
      @indent ||= "\t\t"
    end 
  end
end