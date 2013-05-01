require 'spec_helper'
require 'patentagent/patent_num'

describe PatentAgent::PatentNum do
  
  context PatentAgent::PatentNumUtils do
    let(:obj) {Object.new}
    
    before do
      obj.extend PatentAgent::PatentNumUtils
    end

    %w[4,555,666 5,121,121 6,333,333 7,555,991].each do |num|
      it "#valid_(us)_patent_number for #{num}" do
        expect(obj.valid_us_patent_number?(num)).to be_true
        expect(obj.valid_patent_number?(num)).to be_true
      end
      pnum = num.delete(',')
      it "#valid_(us)_patent_number for #{pnum}" do
        expect(obj.valid_us_patent_number?(pnum)).to be_true
        expect(obj.valid_patent_number?(pnum)).to be_true
      end
      pnum = "US#{num}"
      it "#valid_us_patent_number for #{pnum}" do 
        expect(obj.valid_us_patent_number?(pnum)).to be_true
        expect(obj.valid_patent_number?(pnum)).to be_true
      end

      %w[A B].each do |kind|
        pnum = "US#{num}.#{kind}1"
        it "#valid_us_patent_number for #{pnum}" do
          expect(obj.valid_us_patent_number?(pnum)).to be_true
          expect(obj.valid_patent_number?(pnum)).to be_true
        end
        it "#valid_patent_number? for #{pnum}" do
          expect(obj.valid_patent_number?(pnum)).to be_true
        end
      end
    end
  end  

  context PatentAgent::PatentNum do
    let(:num)     {"US7,267,263.B1"}
    let(:patent)  {PatentAgent::PatentNum.new(num) }

    it "should return an object" do
      expect(patent).to_not be_nil
    end

    it "should output a string on to_s" do
      expect(patent.to_s).to eq num
    end

    it "should be a #valid? object" do
      expect(patent.valid?).to be_true
    end

    it "should have a #number" do
      expect(patent.number).to eq "7267263"
    end

    it "should have a US country code" do
      expect(patent.country_code).to eq "US"
    end

    it "should have a kind code" do
      expect(patent.kind).to eq "B1"
    end
  end

  context "Check validity of patent numbers" do
    %w[US8,267,263.B1 US8267263 8267263.A1 8267263 8,267,263].each do |pnum|
      it "#{pnum} should be #valid?" do
        pat = PatentAgent::PatentNum.new(pnum)
        expect(pat.number).to eq "8267263"
        expect(pat.valid?).to be_true
      end
    end
    %w[US3,267,263.B1 8267263.A7 8267263.C1 12345 555555 8267263-B1].each do |pnum|
      it "#{pnum} should not be #valid?" do
        pat = PatentAgent::PatentNum.new(pnum)
        expect(pat.valid?).to be_false
      end
    end
  end


  context "Country Codes" do
    base = "456789"

    %w[CN JP AZ].each do |cc|
      pnum = "#{cc}#{base}"
      it "Valid Country Code: #{cc}" do
        pat = PatentAgent::PatentNum.new(pnum)
        expect(pat.country_code).to eq cc
        expect(pat.valid?).to be_true
      end
    end
    
    %w[USA JPN AUS].each do |cc|
      pnum = "#{cc}#{base}"
      it "Invalid Country Code: #{cc}" do
        pat = PatentAgent::PatentNum.new(pnum)
        expect(pat.country_code).to eq nil
        expect(pat.valid?).to be_false
      end
    end
  end

  context "Kind Codes" do
    it "should have an A1 code" do
      PatentAgent::PatentNum.new("CN456505.A1").kind.should eq "A1"
    end

    it "should have no code" do
      PatentAgent::PatentNum.new("az456505").kind.should eq ""
    end
  end

  context "ReIssue" do
    let(:pnum) {"RE55434"}
    let(:reissue) {PatentAgent::PatentNum.new(pnum)}

    it "should be a #valid? object" do
      expect(reissue.valid?).to be_true
    end

    it "should have a #number" do
      expect(reissue.number).to eq "55434"
    end

    it "should have a US country code" do
      expect(reissue.country_code).to eq "US"
    end

    it "should have a kind code" do
      expect(reissue.kind).to eq ""
    end
  end
end