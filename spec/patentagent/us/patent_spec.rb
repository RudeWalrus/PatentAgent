require 'spec_helper'

describe PatentAgent::USPatent do
    
  let(:pnum)          {"US6266379"}
  #let(:html)          {File.read(File.dirname(__FILE__) + "/../../fixtures/#{pnum}.html") }
  subject(:patent)    {PatentAgent::USPatent.new(pnum)}

  context "#new", vcr: true do    
    # before(:each) do
    #   PatentAgent::USClient.stub(:get_from_url).and_return(html)  
    # end
    
    it {should be}
      
    its(:patent_num) {should be_valid} 
    
    it "has a valid PatentNum member" do
      expect(patent.patent_num.number).to eq "6266379"
      expect(patent.patent_num.country_code).to eq "US"
    end

    its(:options) {should have_key(:debug)}
    
    it {should_not be_valid_html}
    it {should_not be_valid}
    
    its(:fetch) {should be_valid_html}
    its(:fetch) {should be_valid}
  
    its(:debug) {should be_false}
 
    it "is not valid with invalid patent number" do
      PatentAgent::USPatent.new("US555").should_not be_valid
    end
  
    it "invalid patent number raises an error" do
      PatentAgent::USPatent.new("MyPatent5555").should raise_error
    end

    it "responds to #debug" do
      patent.respond_to?(:debug).should be_true
    end

    it "prints debug output if enabled" do
      pat = PatentAgent::USPatent.new(pnum, :debug => true)
      pat.debug.should be_true
    end

    it "prints log message when enabled" do
      pat = PatentAgent::USPatent.new(pnum, :debug => true)
      pat.should_receive(:log).at_least(:once)
      pat.fetch.parse
    end
  end
  
  context "HTTP Errors" do
    it "#valid? returns false on HTTP error" do
      RestClient.stub(:get).and_raise("HTTP Error")
      PatentAgent::USPatent.new(pnum).fetch.valid?.should be_false
    end
  end
      
  context "Fetch", vcr: true do
         
    before(:each) do
      @patent = PatentAgent::USPatent.new(pnum).fetch.parse
    end 
   
    it "#valid_html? is true" do
      expect(@patent.valid_html?).to be_true
     end
     
    it "Has a valid title" do
      @patent.title.should == Array("Digital transmitter with equalization")
    end
   
    it "has one inventor" do
      @patent.inventors.should have(1).items
    end
   
    it "has 41 claims" do
       @patent.claims.should have(41).items
       @patent.claims.should_not have(40).items
    end
   
    it "has 12 indep claims" do
       @patent.claims.indep_claims.should have(12).items
       @patent.claims.indep_claims.should_not have(20).items
    end
   
    it "has exaclty 29 dep claims" do
       @patent.claims.dep_claims.should have(29).items
       @patent.claims.dep_claims.should_not have(20).items
    end
       
    it "has an App Number" do
       @patent.app_number.should == Array("08/882,252")
    end
   
    it "has an Filed Date " do
       @patent.filed.should == Array("June 25, 1997")
    end
   
    it "has many Figures" do
       @patent.figures.should have_at_least(1).items
       @patent.figures.should be_kind_of(Array)
    end
  end
   
  context "Class Methods", vcr: true do 
    before(:each) do
       @patent = PatentAgent::USPatent.fetch(pnum)
    end
     
    it "creates a patent from #fetch" do
       @patent.should be_kind_of(PatentAgent::USPatent)
    end
     
    it "#valid_html? returns true" do
       expect(@patent.valid_html?).to be_true
    end
    
    it "does not have title and inventor before parse" do
       @patent.title.should be_false
       @patent.inventors.should be_false
    end
    
    it "parses and then generates a title and inventor" do
       @patent.parse
       @patent.title.should be_true
       @patent.inventors.should be_true
    end
  end
end