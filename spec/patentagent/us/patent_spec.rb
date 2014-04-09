require 'spec_helper'

module PatentAgent
  module USPTO
    describe Patent do
      let(:num)           {"6266379"}
      let(:pnum)          {"US" + num}
      subject(:patent)        {Patent.new(pnum)}
      
      context "#new", vcr: true do    
        
        it {should be}
          
        its(:patent_num) {should be_valid} 
        
        it "has a valid PatentNum member" do
          expect(patent.patent_num.number).to eq "6266379"
          expect(patent.patent_num.country_code).to eq "US"
        end

        its(:options) {should have_key(:debug)}
        
        it {should_not be_valid_html}
        it {should_not be_valid}
      
        its(:debug) {should be_false}
     
        it "is not valid with invalid patent number" do
          Patent.new("US555").should_not be_valid
        end
      
        it "invalid patent number raises an error" do
          Patent.new("MyPatent5555").should raise_error
        end

        it "responds to #debug" do
          patent.respond_to?(:debug).should be_true
        end

        it "prints debug output if enabled" do
          pat = Patent.new(pnum, :debug => true)
          pat.debug.should be_true
        end

        it "prints log message when enabled" do
          pat = Patent.new(pnum, :debug => true)
          pat.should_receive(:log).at_least(:once)
          pat.fetch.parse
        end
      end
      
      context "HTTP Errors" do
        it "#valid? returns false on HTTP error" do
          RestClient.stub(:get).and_raise("HTTP Error")
          Patent.new(pnum).fetch.valid?.should be_false
        end
      end

      context '#fetch', vcr: true do
        subject(:result) {patent.fetch}

        context 'Valid' do
          it "returns an instance of Patent" do
            expect(result).to be_kind_of(Patent)
            expect(result).to eq(patent)
          end

          it "is valid and has html" do
            expect(result.html).to match(num)
            expect(result).to be_valid
          end

          it "#valid_html? is true" do
            expect(result).to be_valid_html
          end
        end
         
        context "Fields:" do
          it "Has a valid title" do
            result.title.should == Array("Digital transmitter with equalization")
          end
         
          it "has one inventor" do
            result.inventors.should have(1).items
          end

          it "has an App Number" do
             result.app_number.should == Array("08/882,252")
          end
         
          it "has an Filed Date " do
             result.filed.should == Array("June 25, 1997")
          end
         
          it "has many Figures" do
             result.figures.should have_at_least(1).items
             result.figures.should be_kind_of(Array)
          end
        end

        context "Claims: " do
       
          it "has 41 claims" do
             expect(result.claims.count).to eq(41)
          end
         
          it "has 12 indep claims" do
             result.claims.indep_claims.should have(12).items
          end
         
          it "has exaclty 29 dep claims" do
             result.claims.dep_claims.should have(29).items
          end
        end   
      end

      context "Patent Methods", vcr: true do
        it "US6252976 has Parent Case Text" do
          patent = Patent.new("US6252976").fetch.parse
          #expect(patent.parent_case).to be_true
        end
      end
    end
  end
end