require 'spec_helper'

describe "PatentAgent Logging" do
  it "default creates a logging instance" do
    PatentAgent.logger.should be_kind_of Logger
  end

  it "creates a log file" do
    log_file = "mylogfile.info"
    File.delete log_file if File.exists? log_file
    PatentAgent.logger = log_file
    PatentAgent.log "hello there"
    File.exists?(log_file).should be_true
  end

  it "logs to STDOUT" do
    STDOUT.should_receive(:puts).twice
    PatentAgent.logger = 'stdout'
    PatentAgent.log "Test", "Hello"
  end

  it "logs to STDERR" do
    STDERR.should_receive(:puts).twice
    PatentAgent.logger = 'stderr'
    PatentAgent.log "Test", "Hello"
  end
end