require 'spec_helper'

describe PatentAgent::PTO::Patent do
    
  let(:pnum)  {"US6266379"}
  let(:html)  {File.read(File.dirname(__FILE__) + "/../../fixtures/#{pnum}.html") }
  
  context "#new" do
    
    before(:each) do
      PatentAgent::PTO::Reader.stub(:get_from_url).and_return(html)
      @patent = PatentAgent::PTO::Patent.new(pnum)
    end
    
    it "Blank instance when created with #new" do
      @patent.patent_number.should == pnum
    end
 
    it "should be instantiated" do
      @patent.should be
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
  
  context "HTTP Errors" do
    it "#valid? returns false on HTTP error" do
      RestClient.stub(:get).and_raise("HTTP Error")
      PatentAgent::PTO::Patent.new(pnum).fetch.valid?.should be_false
    end
  end
  
       
  context "Fetch" do
         
    before(:all) do
      PatentAgent::PTO::Reader.stub(:get_from_url).and_return(html)
      @patent = PatentAgent::PTO::Patent.new(pnum)
      @patent.fetch.parse
    end 
   
     it "Should fetch the html" do
       @patent.should be_valid_html
     end
     
     it "Should have a valid title" do
       @patent.title.should == Array("Digital transmitter with equalization")
     end
   
     it "Should have one inventor" do
       @patent.inventors.should have(1).items
     end
   
     it "Should have 41 claims" do
       @patent.claims.should have(41).items
       @patent.claims.should_not have(40).items
     end
   
     it "Should have 12 indep claims" do
       @patent.claims.indep_claims.should have(12).items
       @patent.claims.indep_claims.should_not have(20).items
     end
   
     it "Should have exaclty 29 dep claims" do
       @patent.claims.dep_claims.should have(29).items
       @patent.claims.dep_claims.should_not have(20).items
     end
       
     it "Should have have an App Number" do
       @patent.app_number.should == Array("08/882,252")
     end
   
     it "Should have have an Filed Date " do
       @patent.filed.should == Array("June 25, 1997")
     end
   
     it "Should have many Figures" do
       @patent.figures.should have_at_least(1).items
       @patent.figures.should be_kind_of(Array)
     end
   end
   
   context "Class Methods" do 
     before(:each) do
       PatentAgent::PTO::Reader.stub(:get_from_url).and_return(html)
       @patent = PatentAgent::PTO::Patent.fetch(pnum)
     end
     
     it "should create a patent from #fetch" do
       @patent.should be_kind_of(PatentAgent::PTO::Patent)
     end
     
     it "should be valid html" do
       @patent.should be_valid
     end
    
     it "should not have title and inventor before parse" do
       @patent.title.should be_false
       @patent.inventors.should be_false
     end
    
     it "should parse and create a title and inventor" do
       @patent.parse
       @patent.title.should be_true
       @patent.inventors.should be_true
     end
   end
end