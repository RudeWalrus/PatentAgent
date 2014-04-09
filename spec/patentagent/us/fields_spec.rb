require 'spec_helper'

module PatentAgent
  module USPTO
    describe Fields do
      let(:num)           {"6266379"}
      let(:pnum)          {"US" + num}
      let(:patent)        {Patent.new(pnum).fetch}
      subject(:fields)    {Fields.new(patent)}

      context "#new", vcr: true do     
        it {should be}
        
        it "has a valid PatentNum member" do
          expect(fields.patent.number).to eq "6266379"
          expect(fields.patent.country_code).to eq "US"
        end

        it "has html" do
          expect(fields.html).to match(num)
        end

        it "fields exists but are nil" do
           expect(fields.patent_number).to be_false
           expect(fields.title).to be_false
           expect(fields.abstract).to be_false
           expect(fields.assignees).to be_false
           expect(fields.app_number).to be_false
           expect(fields.filed).to be_false
           expect(fields.inventors).to be_false
           expect(fields.text).to be_false
           expect(fields.parent_case).to be_false
           expect(fields.figures).to be_false
        end
      end  

      context "#parse", vcr: true do
        subject(:data) {fields.parse}
       
        it "returns an instance of Fields" do
          expect(data).to be_kind_of(Fields)
        end

         
        it "has a valid title" do
          data.title.should == Array("Digital transmitter with equalization")
        end
       
        it "has one inventor" do
          data.inventors.should have(1).items
        end
           
        it "has an App Number" do
           data.app_number.should == Array("08/882,252")
        end
       
        it "has an Filed Date" do
           data.filed.should == Array("June 25, 1997")
        end
       
        it "has many Figures" do
           data.figures.should have_at_least(1).items
           data.figures.should be_kind_of(Array)
        end
      end
    end
  end
end