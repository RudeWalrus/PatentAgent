require 'spec_helper'


module PatentAgent

  describe PatentAgent do
    subject(:p) {PatentAgent}
    let(:log_file) {"mylogfile.info"}

    it {should respond_to :logger, :logger=, :log, :dlog}
    its(:logger) {should be_kind_of Logger}
    
    it "creates a log file" do
      File.delete log_file if File.exists? log_file
      p.logger = log_file
      p.log "Header", "Data"
      File.exists?(log_file).should be_true
    end

    context "testing different outputs" do
      let(:log_stream) {StringIO.new}

      before do
        p.should_receive(:initialize_log).at_least(1).times.and_return(Logger.new(log_stream))
      end

      it "logs to STDOUT" do
        p.logger = STDOUT
        p.log "Stdout", "Hello"
        log_stream.string.should match(/STDOUT/)
      end

      it "logs to STDERR" do
        p.logger = STDERR
        p.log "Stderr", "Hello"
        log_stream.string.should match(/STDERR/)
      end

      it "logs an array" do
        p.logger = "mylogfile.info"
        p.log "Array", [1,2,3,4,5]
        log_stream.string.should match(/ARRAY/)
        log_stream.string.should match(/Count: 5/)
      end

      it "logs a hash" do
        p.logger = "mylogfile.info"
        p.log "Hash", {one: 1, two: 2, three: 3 }
        log_stream.string.should match(/HASH/)
        log_stream.string.should match(/Count: 3/)
      end
    end

    context "#dlog" do
      let(:log_stream) {StringIO.new}
      
      before(:each) do
        p.debug = false
        p.logger = log_stream
      end

      it "#debug" do
        expect{p.debug = true}.to change{p.logger.level}.from(Logger::INFO).to(Logger::DEBUG)
      end

      it "Debug output turns on with debug=true" do
        p.dlog "STDOUT", "Test"
        log_stream.string.should_not match /Test/
        p.debug = true 
        p.dlog "STDOUT", "Test"
        log_stream.string.should match /Test/
      end
    end

    describe "quiet" do
      before {PatentAgent.logger.level = Logger::INFO}
      after  {PatentAgent.logger.level = Logger::INFO}
      it "Goes quiet on #quiet" do
        expect{PatentAgent.quiet}.to change{PatentAgent.logger.level}.from(Logger::INFO).to(Logger::FATAL)
      end
    end 
  end
end