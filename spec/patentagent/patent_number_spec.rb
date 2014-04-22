require 'spec_helper'
require 'patentagent/patent_number'

module PatentAgent
  describe PatentNumber do
    
    describe "Valid Patent Numbers" do
      @test= ->(num){
        it "#valid_(us)_patent_number? for #{num}" do
          expect(PatentNumber.valid_us_patent_number?(num)).to be_true
          expect(PatentNumber.valid_patent_number?(num)).to be_true
        end
      }
      
      %w[4,555,666 5,121,121 6,333,333 7,555,991].each do |num|    
        @test.call(num)
        @test.call(num.delete(','))
        @test.call("US#{num}")
        %w[A B].each { |kind| @test.call("US#{num}.#{kind}1") }
      end
    end

    describe "Invalid Patent Numbers" do
      @test= ->(num){
        it "#valid_(us)_patent_number? for #{num}" do
          expect(PatentNumber.valid_us_patent_number?(num)).to be_false
          expect(PatentNumber.valid_patent_number?(num)).to be_false
        end
      }
      
      %w[3,555,666 121,121 6,333,3339 RE555,991].each do |num|    
        @test.call(num)
        @test.call(num.delete(','))
        @test.call("US#{num}")
        %w[A B].each { |kind| @test.call("US#{num}.#{kind}3") }
      end
    end    

    context PatentNumber do
      let(:num)         {"US7,267,263.B1"}
      subject(:patent)  {PatentNumber.new(num) }

      context "US Patents" do
        context "#new object" do
          it "should accept a PatentNumber object" do
            obj = PatentNumber.new(patent)
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
              pat = PatentNumber.new(pnum)
              expect(pat.number).to eq "8267263"
              expect(pat.valid?).to be_true
            end
          end

          %w[US uS Us].each do |cc|
            pnum = "#{cc}5557190"
            it "Valid Country Code: #{cc}" do
              pat = PatentNumber.new(pnum)
              expect(pat.country_code).to eq "US"
              expect(pat.valid?).to be_true
            end
          end
        end

        context "Check invalid patent numbers" do

          %w[8267263.A7 8267263.C1 8267263-B1].each do |pnum|
            it "Should check invalid suffix: #{pnum}" do
              pat = PatentNumber.new(pnum)
              expect(pat.valid?).to be_false
            end
          end

          %w[12345 62134 745454 811511 555555].each do |pnum|
            it "Should check for too short#{pnum}" do
              pat = PatentNumber.new(pnum)
              expect(pat.valid?).to be_false
            end
          end

          %w[US3,267,263.B1 9123456 1234567].each do |pnum|
          it "Should catch bad prefix: #{pnum}" do
            pat = PatentNumber.new(pnum)
            expect(pat.valid?).to be_false
          end
        end

        context "ReIssue" do
          %w[RE55571 RE35,312 RE23234 Re33333 RE33,333].each do |re|
            num = re.to_s.upcase.delete(',')
            reissue = PatentNumber.new(re)
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
              pat = PatentNumber.new(pnum)
              expect(pat.country_code).to eq cc
              expect(pat.valid?).to be_true
            end
          end
          %w[USA JPN AUS].each do |cc|
            pnum = "#{cc}#{base}"
            it "Invalid Country Code: #{cc}" do
              pat = PatentNumber.new(pnum)
              expect(pat.country_code).to eq nil
              expect(pat.valid?).to be_false
            end
          end
        end
          context "Kind Codes" do
            it "should have an A1 code" do
              PatentNumber.new("CN456505.A1").kind.should eq "A1"
            end

            it "should have no code" do
              PatentNumber.new("az456505").kind.should eq ""
            end
          end
        end
      end
    end
  end
end