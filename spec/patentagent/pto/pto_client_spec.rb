require 'spec_helper'

module PatentAgent::PTO
  class Client; end;
end

describe PatentAgent::PTO::Client do
  
  let(:patent_number)  {"US6266379"}
  let(:html) { File.read(File.dirname(__FILE__) + "/../../fixtures/#{patent_number}" + '.html') }
  let(:patent) {PatentAgent::Patent.new(patent_number)}
  
  context "#new" do
  
    before(:each) do
      PatentAgent::PTO::Client.stub(:get_from_url).and_return(html)
    end
    
    it "Returns a Patent" do
      patent.should be_kind_of(Patent)
    end

    it "should be instantiated" do
      patent.should be
    end

    it "Blank instance when created with #new" do
      patent.patent_number.should == patent_number
    end
    
    it "should have options.debug key" do
      @patent.options.should have_key(:debug)
    end
    
    it "#valid_html? should be false before fetch" do
      @patent.should_not be_valid_html
   end
   
   it "#fetch grabs valid patent from file" do
      @patent.fetch.should be_valid_html
    end
   
   it "#valid? returns false before fetch" do
     @patent.valid?.should be_false
   end
   
    it "#valid returns true after fetch" do
      @patent.fetch.valid?.should be_true
    end
 
    it "should not be valid with invalid patent number" do
      PatentAgent::PTO::Patent.new("US555").should_not be_valid
    end
  
    it "invalid patent number should raise an error" do
      PatentAgent::PTO::Patent.new("MyPatent5555").should raise_error
    end
  
    it "should print debug output if enabled" do
      patent = PatentAgent::PTO::Patent.new(pnum, :debug => true)
      patent.debug.should be_true
    end
    
    it "should print log message when enabled" do
      PatentAgent.should_receive(:log).at_least(:once)
      PatentAgent::PTO::Patent.new(pnum, :debug => true).fetch.parse
    end
  end
end