require 'spec_helper'


module PatentAgent
# dummy class used for tests
  class PatentLog 
      include Logging
  end


  describe "PatentAgent::Logging" do
    let(:p_log) {PatentLog.new}

    context 'PatentAgent' do
      it "has #log on self" do
        PatentAgent.should respond_to(:log)
      end

      it "responds to create_log" do
        PatentAgent.should respond_to(:create_log)
      end
    end

    context "mixin" do

      it "responds to #log after mix-in" do
        p_log.should respond_to(:log)
      end

      it "responds to #debug after mix-in" do
        p_log.should respond_to(:debug)
      end


      it "creates a log file" do
        log_file = "mylogfile.info"
        File.delete log_file if File.exists? log_file
        p_log.logger = log_file
        p_log.log "Header", "Data"
        File.exists?(log_file).should be_true
      end
    end

    context "testing different outputs" do
      let(:log_stream) {StringIO.new}

      before do
        p_log.should_receive(:create_log).and_return(Logger.new(log_stream))
        p_log.debug = true
      end

      it "logs to STDOUT" do
        p_log.logger = 'stdout'
        p_log.log "Stdout", "Hello"
        log_stream.string.should match(/STDOUT/)
      end

      it "logs to STDERR" do
        p_log.logger = 'stderr'
        p_log.log "Stderr", "Hello"
        log_stream.string.should match(/STDERR/)
      end

      it "logs an array" do
        p_log.logger = "mylogfile.info"
        p_log.log "Array", [1,2,3,4,5]
        log_stream.string.should match(/ARRAY/)
        log_stream.string.should match(/Count: 5/)
      end

      it "logs a hash" do
        p_log.logger = "mylogfile.info"
        p_log.log "Hash", {one: 1, two: 2, three: 3 }
        log_stream.string.should match(/HASH/)
        log_stream.string.should match(/Count: 3/)
      end
    end
  end
end