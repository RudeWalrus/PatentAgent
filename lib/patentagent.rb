require 'nokogiri'
require 'rest_client'
require 'set'
require 'logger'

$: << File.dirname(__FILE__) + '../patentagent'

require 'patentagent/util'
require 'patentagent/claim'
require 'patentagent/ops/ops_utility'
require 'patentagent/ops/ops_reader'
require 'patentagent/ops/ops_patent'

require 'patentagent/pto/pto_reader'
require 'patentagent/pto/pto_patent'


module PatentAgent
 

  class << self
    
    def version
        version_path = File.dirname(__FILE__) + "/../VERSION"
        return File.read(version_path).chomp if File.file?(version_path)
        "0.0.1"
    end
  
    # Setup the logger.
    # Value should be a logger but can can be stdout, stderr, or a filename.
    # You can also configure logging by the environment variable PATENTAGENT_LOG.
    def logger=(log)
      @@log = create_log log
    end
  
    def logger # :nodoc:
      @@env_log || @@log
    end
  
    #
    # a standard logging function that can print out
    # many kinds of objects from PatentAgent (Hashes, Arrays, etc)
    # Dumps data into whatever PatentAgent.logger points
    #
    def log(header = "no header", obj = nil)
      logger << "\t#{header.to_s.upcase}:#{"="*5+">"}"
  		indent = "\t\t"
  		case obj
  		  when Array
          logger << "Count: #{obj.size}\n"
  				obj.each {|item| PatentAgent.logger << "#{indent}#{item}\n"}
        when Hash
          logger << "Count: #{obj.size}\n"
          obj.map {|k,v| PatentAgent.logger << "#{indent}#{k}: #{v}\n"}
  			when nil
  			  logger << "\n"
  			else
  				logger << "#{indent}#{obj}\n"
  		end		
  	end

  

    # Create a log that respond to << like a logger
    # param can be 'stdout', 'stderr', a string (then we will log to that file) or a logger (then we return it)
    def create_log(param)
      if param
        if param.is_a? String
          if param == 'stdout'
            stdout_logger = Class.new do
              def << obj
                STDOUT.puts obj
              end
            end
            stdout_logger.new
          elsif param == 'stderr'
            stderr_logger = Class.new do
              def << obj
                STDERR.puts obj
              end
            end
            stderr_logger.new
          else
            file_logger = Class.new do
              attr_writer :target_file
              def << obj
                File.open(@target_file, 'a') { |f| f.puts obj }
              end
            end
            logger = file_logger.new
            logger.target_file = param
            logger
          end
        else
          param
        end
      end
    end
  end
  @@env_log = create_log ENV['PATENTAGENT_LOG']
  @@log = nil
  self.logger = Logger.new(STDERR)
  #self.logger = create_log "patentagent.output"
  
  
  def to_symbol(name)
    symbol = name.to_s.downcase
    symbol.gsub(" ", "_")
  end
  
  def self.symbol_to_string(symbol)
    return symbol if symbol.is_a?(String)
    str = Array(symbol.to_s.split("_"))
    str.map(&:capitalize).join(" ")
  end 


end