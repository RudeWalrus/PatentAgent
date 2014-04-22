require 'spec_helper'

module PatentAgent
  module USPTO
    describe Fields, vcr: true do
      let(:num)           {"6266379"}
      let(:cc)            {"US"}
      let(:pnum)          {cc + num}
      let(:html)          {File.read(File.dirname(__FILE__) + "/../../fixtures/#{pnum}.html") }
      subject(:fields)    {Fields.new(html)}

      context "#initialize" do     
        it {should be}

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

      context "#parse_field" do
        it "parses a single field" do
          fields.parse_field(:title).should match("Digital transmitter with equalization") 
        end
      end

      context "#parse" do
        subject(:data) {fields.parse}
       
        it "returns an instance of Fields" do
          expect(data).to be_kind_of(Fields)
        end

        it "has an valid abstract" do
           data.abstract.should match("An equalizer provided in a digital transmitter compensates for attenuation")
        end
         
        it "has a valid title" do
          data.title.should match("Digital transmitter with equalization")
        end
       
        it "has one inventor" do
          data.inventors.should have(1).items
        end
           
        it "has an App Number" do
           data.app_number.should match("08/882,252")
        end
       
        it "has an Filed Date" do
           data.filed.should match("June 25, 1997")
        end

        it "has an valid text" do
           data.text.should match("data modems have long")
        end
       
        it "has many Figures" do
           data.figures.should have_at_least(1).items
           data.figures.should be_kind_of(Array)
        end
      end

      context "self.each" do
        it "returns each field" do
          @count = 0
          Fields.each do |field, obj|
            @count += 1
          end
        expect(@count).to eq Fields.count
        end
      end

      context "self.add" do
        before do
          gross = /Primary Examiner:<\/I>(.*?)<BR>/mi
          fine = /<\/I>(.*?)<BR>/mi
          Fields.add :prime_examiner, gross,fine
        end

        it "Adds a search method instance variable" do
          expect(fields).to respond_to(:prime_examiner)
        end
        it "Adds a search method" do
          expect(fields.parse.prime_examiner).to eq "Ghebretinsae; Temesghen"
        end
      end 
    end
  end
end