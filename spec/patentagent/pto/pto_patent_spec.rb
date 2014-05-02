require 'spec_helper'

module PatentAgent
  module PTO
    describe PtoPatent do
      let(:number)           {"6266379"}
      let(:cc)                {"US"}
      let(:patent_num)       {cc + number}
      let(:pnum)             {PatentNumber.new(patent_num)}
      let(:html)             {PTOReader.read(pnum)}
      subject(:patent)       {PtoPatent.new(pnum, html)}
      
      describe "#initialize", vcr: true do    
        
        it {should be_kind_of(PtoPatent)}
     
          
        its(:patent_num) {should be_valid} 
        its("patent_num.number") {should eq number}
        its("patent_num.cc") {should eq cc}

     
        it "is not valid with invalid patent number" do
          PtoPatent.new("US555", html).should_not be_valid
        end
      
        it "invalid patent number raises an error" do
          PtoPatent.new("MyPatent5555", html).should raise_error
        end
      end

      describe '#fetch', :vcr do

        it "is valid" do
          expect(patent).to be_valid
        end
 
        context "Fields:" do
          its(:title)       {should match "Digital transmitter with equalization"}
          its(:app_number)  {should match "08/882,252"}
          its(:file_date)   {should match "June 25, 1997"}
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
          its("claims")               {should have(41).items}
          
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

      {
        title:      "Digital transmitter with equalization",
        inventors:  ["Dally; William J."],
        assignees:  ["Massachusetts Institute of Technology"],
        file_date:      "June 25, 1997"
      }.each do |key, value|
        it ":#{key}" do
            expect(hash).to have_key key
            expect(hash[key]).to eq value
        end
      end
        
      end
    end
  end
end