require 'spec_helper'

module PatentAgent
  describe USPatent do
      
    let(:pnum)          {"US6266379"}
    #let(:html)          {File.read(File.dirname(__FILE__) + "/../../fixtures/#{pnum}.html") }
    subject(:patent)    {USPatent.new(pnum)}

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
        USPatent.new("US555").should_not be_valid
      end
    
      it "invalid patent number raises an error" do
        USPatent.new("MyPatent5555").should raise_error
      end

      it "responds to #debug" do
        patent.respond_to?(:debug).should be_true
      end

      it "prints debug output if enabled" do
        pat = USPatent.new(pnum, :debug => true)
        pat.debug.should be_true
      end

      it "prints log message when enabled" do
        pat = USPatent.new(pnum, :debug => true)
        pat.should_receive(:log).at_least(:once)
        pat.fetch.parse
      end
    end
    
    context "HTTP Errors" do
      it "#valid? returns false on HTTP error" do
        RestClient.stub(:get).and_raise("HTTP Error")
        USPatent.new(pnum).fetch.valid?.should be_false
      end
    end
        
    context "#parse", vcr: true do
      let(:data) {patent.fetch.parse}
     
      it "#parse returns an instance of USPatent" do
        expect(data).to be_kind_of(USPatent)
        expect(data).to eq(patent)
      end
      it "#valid_html? is true" do
        expect(data.valid_html?).to be_true
       end
       
      it "Has a valid title" do
        data.title.should == Array("Digital transmitter with equalization")
      end
     
      it "has one inventor" do
        data.inventors.should have(1).items
      end
     
      it "has 41 claims" do
         expect(data.claims.count).to eq(41)
      end
     
      it "has 12 indep claims" do
         data.claims.indep_claims.should have(12).items
      end
     
      it "has exaclty 29 dep claims" do
         data.claims.dep_claims.should have(29).items
      end
         
      it "has an App Number" do
         data.app_number.should == Array("08/882,252")
      end
     
      it "has an Filed Date " do
         data.filed.should == Array("June 25, 1997")
      end
     
      it "has many Figures" do
         data.figures.should have_at_least(1).items
         data.figures.should be_kind_of(Array)
      end
    end
     
    context "Class Methods", vcr: true do 
      before(:each) do
         @patent = USPatent.fetch(pnum)
      end
       
      it "creates a patent from #fetch" do
         @patent.should be_kind_of(PatentAgent::USPatent)
      end
       
      it "#valid_html? returns true" do
         expect(@patent).to be_valid_html
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

    context "Patent Methods", vcr: true do
      it "US6252976 has Parent Case Text" do
        patent = USPatent.new("US6252976").fetch.parse
        #expect(patent.parent_case).to be_true
      end
    end
  end
end