require 'spec_helper'

module PatentAgent
  module PTO
    describe Fields, vcr: true do
      let(:num)           {"6266379"}
      let(:cc)            {"US"}
      let(:pnum)          {cc + num}
      let(:html)          {File.read(File.dirname(__FILE__) + "/../../fixtures/#{pnum}.html") }
      subject(:fields)    {Fields.new(html)}

      describe "#initialize" do     
        it {should be}
        it {should be_kind_of(Fields)}

        it "has html" do
          expect(fields.html).to match(num)
        end

        it "fields exists " do
           expect(fields.patent_number).to be
           expect(fields.title).to be
           expect(fields.abstract).to be
           expect(fields.assignees).to be
           expect(fields.app_number).to be
           expect(fields.filed).to be
           expect(fields.inventors).to be
           expect(fields.text).to be
           expect(fields.parent_case).to be
           expect(fields.figures).to be
        end
      end  

      describe "validate data" do
        its(:abstract)    {should match("An equalizer provided in a digital transmitter compensates for attenuation") }
        its(:title)       {should match("Digital transmitter with equalization")}
        its(:inventors)   {should have(1).items }
        its(:app_number)  {should match("08/882,252") }
        its(:filed)       {should match("June 25, 1997") }
        its(:text)        {should match("data modems have long")}
        its(:figures)     {should have_at_least(1).items}
        its(:figures)     {should be_kind_of(Array)}     
      end

      describe "#parse_field" do
        it "parses a single field" do
          fields.parse_field(:title).should match("Digital transmitter with equalization") 
        end
      end

      describe "self.each" do
        it "returns each field" do
          @count = 0
          Fields.each do |field, obj|
            @count += 1
          end
        expect(@count).to eq Fields.count
        end
      end

      describe "self.add" do
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