require 'spec_helper'

include PatentAgent

module PatentAgent
  describe PatentNumber do
    let(:num)   {7123456}
    let(:nums) {["8,705,606", "8,681,837", "8,675,483", "8,665,940", "8,659,325", "8,654,573", "8,564,328", "8,311,147"]}
    let(:pnum)  {num.to_s}
    subject(:p_obj) {PatentNumber.new(pnum)}

    describe "PatentNumber() coersion" do

      it {should be}

      it "Coerses PatentNumber" do
        PatentNumber(p_obj).should eq p_obj
      end

      it "Coerses String" do
        obj = PatentNumber(pnum)
        obj.should be_kind_of PatentNumber
        obj.number.should eq pnum
      end

      it "Coerses Integer" do
        obj = PatentNumber(num)
        obj.should be_kind_of PatentNumber
        obj.number.should eq pnum
      end

      it "coerces array of strings" do
        objs = PatentNumber(nums)
        objs.should have(8).items
        objs.should be_all {|x| x.is_a? PatentNumber}
      end

      it "coerces array of PatentNumbers" do
        pnums = nums.map{|x| PatentNumber(x) }
        objs = PatentNumber(pnums)
        objs.should have(8).items
        objs.should be_all {|x| x.is_a? PatentNumber}
      end

    end
    
    describe "Valid Patent Numbers" do
      @test= ->(num){
        it "#valid_(us)_patent_number? for #{num}" do
          expect(PatentNumber.valid_us_patent_number?(num)).to be_true
          expect(PatentNumber.valid_patent_number?(num)).to be_true
        end
      }
      
      %w[4,555,666 5,121,121 6,333,333 7,555,991 8,333,121].each do |num|    
        @test.call(num)
        @test.call(num.delete(','))
        @test.call("US#{num}")
        %w[A B].each { |kind| @test.call("US#{num}.#{kind}1") }
      end
    end

    describe "Invalid Patent Numbers" do
      before {PatentAgent.quiet}
      after  {PatentAgent.logger.level = Logger::INFO}
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

    context "Class Methods" do
      let(:good)         {"US7,267,263.B1"}
      let(:bad)         {"US3,267,263.B1"}

      {cc_of: "US", kind_of: "B1", number_of: "7267263"}.each do |proc, value|
        it "checks :#{proc} with good" do
          PatentNumber.send(proc.to_sym, good).should eq value
        end
      end
      %w[cc_of kind_of number_of].each do |proc|
        it "checks :#{proc} with bad" do
          PatentNumber.send(proc.to_sym, bad).should eq "invalid"
        end
      end
    end

    context "methods" do
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
          before {PatentAgent.quiet}
          after  {PatentAgent.logger.level = Logger::INFO}
          %w[8267263.A7 8267263.C1 8267263-B1].each do |pnum|
            it "Should check invalid suffix: #{pnum}" do
              pat = PatentNumber.new(pnum)
              expect(pat.valid?).to be_false
            end
          end

          %w[12345 62134 745454 811511 555555].each do |pnum|
            it "check for too short#{pnum}" do
              pat = PatentNumber.new(pnum)
              expect(pat.valid?).to be_false
            end
            it "self.cc_of, self.number_of, self.kind_of are invalid for #{pnum}" do
              expect(PatentNumber.cc_of(pnum)).to eq "invalid"
              expect(PatentNumber.kind_of(pnum)).to eq "invalid"
              expect(PatentNumber.number_of(pnum)).to eq "invalid"
            end
          end

          %w[US3,267,263.B1 9123456 1234567].each do |pnum|
          it "Should catch bad prefix: #{pnum}" do
            pat = PatentNumber.new(pnum)
            expect(pat.valid?).to be_false
          end
        end

        context "ReIssue" do
          %w[RE55571 RE35,312 RE23234 Re33333 RE33,333].each { |re|
            num = re.to_s.upcase.delete(',')
            reissue = PatentNumber.new(re)
            it "#{re} is a #valid? object" do
              expect(reissue.valid?).to be_true
            end

            it "#{re} has a #number" do
              expect(reissue.number).to eq num
            end

            it "#{re} has a US country code" do
              expect(reissue.country_code).to eq "US"
            end

            it "#{re} has a kind code" do
              expect(reissue.kind).to eq ""
            end
          }
          it "special case: USRE" do
            %w[USRE55571 USRE35,312 USRE23234 UsRe33333 UsRe33,333].each { |re|
              num = re.to_s.upcase.delete(',')
              reissue = PatentNumber.new(re)
              expect(reissue.valid?).to be_true
              expect(reissue.number).to eq num[2..-1]
              expect(reissue.country_code).to eq "US"
              expect(reissue.kind).to eq ""
            }
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