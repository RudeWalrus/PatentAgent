require 'spec_helper'

module PatentAgent
  module PTO
    describe Patent do
      let(:number)           {"6266379"}
      let(:cc)                {"US"}
      let(:patent_num)       {cc + number}
      let(:pnum)             {PatentNumber.new(patent_num)}
      let(:html)             {File.read(File.dirname(__FILE__) + "/../../fixtures/US6266379.html") }
      subject(:patent)       {Patent.new(pnum, html)}
      
      describe "#initialize", :vcr do 
        it                    {should be_kind_of(Patent)}
        it                    {should respond_to :patent, :fields, :claims}
      
        its(:patent)           {should be_valid} 
        its("patent.number")   {should eq number}
        its("patent.cc")       {should eq cc}

        it "invalid patent number raises an error" do
          Patent.new("MyPatent5555", html).should raise_error
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

      describe '#to_h', vcr: true do
        subject(:hash) {patent.to_h}

        {
          title:      "Digital transmitter with equalization",
          inventors:  ["Dally; William J."],
          assignees:  ["Massachusetts Institute of Technology"],
          file_date:   "June 25, 1997"
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