require 'spec_helper'

describe "PatentAgent Logging" do
  it "default creates a logging instance" do
    PatentAgent.logger.should be_kind_of Logger
  end

  it "creates a log file" do
    log_file = "mylogfile.info"
    File.delete log_file if File.exists? log_file
    PatentAgent.logger = log_file
    PatentAgent.log "Header", "Data"
    File.exists?(log_file).should be_true
  end

  context "testing different outputs" do
    let(:log_stream) {StringIO.new}
    before do
      PatentAgent.should_receive(:create_log).and_return(Logger.new(log_stream))
      PatentAgent.debug = true
    end

    it "logs to STDOUT" do
      PatentAgent.logger = 'stdout'
      PatentAgent.log "STDOUT", "Hello"
      log_stream.string.should match(/STDOUT/)
    end

    it "logs to STDERR" do
      PatentAgent.logger = 'stderr'
      PatentAgent.log "STDERR", "Hello"
      log_stream.string.should match(/STDERR/)
    end

    it "logs an array" do
      PatentAgent.logger = "mylogfile.info"
      PatentAgent.log "Array", [1,2,3,4,5]
      log_stream.string.should match(/ARRAY/)
      log_stream.string.should match(/Count: 5/)
    end

    it "logs a hash" do
      PatentAgent.logger = "mylogfile.info"
      PatentAgent.log "Hash", {one: 1, two: 2, three: 3 }
      log_stream.string.should match(/HASH/)
      log_stream.string.should match(/Count: 3/)
    end
  end
end