require 'spec_helper'

module PatentAgent
  module USPTO
    describe Patent do
      let(:number)           {"6266379"}
      let(:cc)                {"US"}
      let(:patent_num)       {cc + number}
      let(:pnum)             {PatentNum.new(patent_num)}
      subject(:patent)       {Patent.new(pnum)}
      
      context "#initialize", vcr: true do    
        
        it {should be}
          
        its(:patent_num) {should be_valid} 
        its(:options) {should have_key(:debug)}
        its(:debug) {should be_false}
        its("patent_num.number") {should eq number}
        its("patent_num.cc") {should eq cc}

     
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
          pat.fetch
        end
      end
      
      describe "HTTP Errors" do
        it "#valid? returns false on HTTP error" do
          RestClient.stub(:get).and_raise("HTTP Error")
          Patent.new(pnum).fetch.valid?.should be_false
        end
      end

      # context "Patent#fetch", vcr: true do
      #   it "gets the full patent using class method" do
      #     pat = Patent.fetch("US8011234")
      #     expect(pat).to be_valid
      #   end
      # end

      describe '#fetch', vcr: true do
        it "is class of USPTO::Patent" do
          expect(patent).to be_kind_of(PatentAgent::USPTO::Patent)
        end

        it "is valid and has html" do
          expect(patent.html).to match(number)
          expect(patent).to be_valid
          expect(patent).to be_valid_html
        end
 
        context "Fields:" do
          its(:title)       {should match "Digital transmitter with equalization"}
          its(:app_number)  {should match "08/882,252"}
          its(:filed)       {should match "June 25, 1997"}
          its(:inventors)   {should have(1).items}
         
          it "has many Figures" do
             patent.figures.should have_at_least(1).items
             patent.figures.should be_kind_of(Array)
          end
        end

        context "Claims: " do
          its("claims.count")         {should eq 41}
          its("claims.indep_claims")  {should have(12).items}
          its("claims.dep_claims")    {should have(29).items}
          its("claims.parsed_claims") {should have(41).items}
          
          it "array access" do
            expect(patent.claims[15].text).to  match "15.  A digital transmitter "
          end
          it "#each" do
              patent.claims.each {|k,v| expect(v.text).to be_kind_of(String)} 
          end
        end   
      end

      describe '#to_hash', vcr: true do
        subject(:hash) {patent.to_hash}
        its(:size) {should eq 10}
        it ":title" do
          expect(hash.fetch(:title)).to eq "Digital transmitter with equalization"
        end
        it ":inventors" do
          expect(hash.fetch(:inventors)).to eq ["Dally; William J."]
        end
        it ":assignees" do
          expect(hash.fetch(:assignees)).to eq ["Massachusetts Institute of Technology"]
        end
      end
    end
  end
end