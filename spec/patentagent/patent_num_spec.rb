require 'spec_helper'
require 'patentagent/patent_num'

module PatentAgent
  describe PatentNum do
    
    context PatentNumUtils do
      let(:obj) {Object.new}
      
      before do
        obj.extend PatentNumUtils
      end

      %w[4,555,666 5,121,121 6,333,333 7,555,991].each do |num|
        it "#valid_(us)_patent_number? for #{num}" do
          expect(obj).to be_valid_us_patent_number(num)
          expect(obj).to be_valid_patent_number(num)
        end
        pnum = num.delete(',')
        it "#valid_(us)_patent_number? for #{pnum}" do
          expect(obj).to be_valid_us_patent_number(pnum)
          expect(obj).to be_valid_patent_number(pnum)
        end
        pnum = "US#{num}"
        it "#valid_us_patent_number? for #{pnum}" do 
          expect(obj).to be_valid_us_patent_number(pnum)
          expect(obj).to be_valid_patent_number(pnum)
        end

        %w[A B].each do |kind|
          pnum = "US#{num}.#{kind}1"
          it "#valid_(us)_patent_number? for #{pnum}" do
            expect(obj).to be_valid_us_patent_number(pnum)
            expect(obj).to be_valid_patent_number(pnum)
          end
        end
      end
    end  

    context PatentNum do
      let(:num)         {"US7,267,263.B1"}
      subject(:patent)  {PatentAgent::PatentNum.new(num) }

      context "US Patents" do
        context "#new object" do

          it "should accept a PatentNum object" do
            obj = PatentNum.new(patent)
            obj.to_s.should eq num
          end

          it                    {should_not be_nil}
          it                    {should be_valid}

          its(:to_s)            {should eq num}
          its(:number)          {should eq "7267263" }
          its(:country_code)    {should eq "US" }
          its(:kind)            {should eq "B1" }
        
        end

        context "Check validity of patent numbers" do
          %w[US8,267,263.B1 US8267263 8267263.A1 8267263 8,267,263].each do |pnum|
            it "#{pnum} should be #valid?" do
              pat = PatentNum.new(pnum)
              expect(pat.number).to eq "8267263"
              expect(pat.valid?).to be_true
            end
          end

          %w[US uS Us].each do |cc|
            pnum = "#{cc}5557190"
            it "Valid Country Code: #{cc}" do
              pat = PatentNum.new(pnum)
              expect(pat.country_code).to eq "US"
              expect(pat.valid?).to be_true
            end
          end
        end

        context "Check invalid patent numbers" do

          %w[8267263.A7 8267263.C1 8267263-B1].each do |pnum|
            it "Should check invalid suffix: #{pnum}" do
              pat = PatentNum.new(pnum)
              expect(pat.valid?).to be_false
            end
          end

          %w[12345 62134 745454 811511 555555].each do |pnum|
            it "Should check for too short#{pnum}" do
              pat = PatentNum.new(pnum)
              expect(pat.valid?).to be_false
            end
          end

          %w[US3,267,263.B1 9123456 1234567].each do |pnum|
          it "Should catch bad prefix: #{pnum}" do
            pat = PatentNum.new(pnum)
            expect(pat.valid?).to be_false
          end
        end

        context "ReIssue" do
          %w[RE55571 RE35,312 RE23234 Re33333 RE33,333].each do |re|
            num = re.to_s.upcase.delete(',')
            reissue = PatentNum.new(re)
            it "is a #valid? object" do
              expect(reissue.valid?).to be_true
            end

            it "has a #number" do
              expect(reissue.number).to eq num
            end

            it "has a US country code" do
              expect(reissue.country_code).to eq "US"
            end

            it "has a kind code" do
              expect(reissue.kind).to eq ""
            end
          end
        end
      end

      context "Non US Patents" do
        context "Country Codes" do
          base = "456789"
          %w[CN JP AZ].each do |cc|
            pnum = "#{cc}#{base}"
            it "Valid Country Code: #{cc}" do
              pat = PatentNum.new(pnum)
              expect(pat.country_code).to eq cc
              expect(pat.valid?).to be_true
            end
          end
          %w[USA JPN AUS].each do |cc|
            pnum = "#{cc}#{base}"
            it "Invalid Country Code: #{cc}" do
              pat = PatentNum.new(pnum)
              expect(pat.country_code).to eq nil
              expect(pat.valid?).to be_false
            end
          end
        end
          context "Kind Codes" do
            it "should have an A1 code" do
              PatentNum.new("CN456505.A1").kind.should eq "A1"
            end

            it "should have no code" do
              PatentNum.new("az456505").kind.should eq ""
            end
          end
        end
      end
    end
  end
end