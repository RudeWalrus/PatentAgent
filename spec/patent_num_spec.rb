require 'spec_helper'
require 'patentagent/patent_num'


describe PatentAgent::PatentNum do
  
  context "Basic Properties" do
  
    let(:patent) {PatentAgent::PatentNum.new("US7,267,263.B1") }

    it "should return an object" do
      expect(patent).to_not be_nil
    end

    it "should output a string on puts" do
      expect(patent.to_s).to eq "US7267263.B1"
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

  context "Various valid patents" do
    it "should be #valid?" do
      [
      "US8,267,263.B1",
      "US8267263",
      "8267263.A1",
      "8267263"
      ].each  do |pnum|
        pat = PatentAgent::PatentNum.new(pnum)
        expect(pat.number).to eq "8267263"
      end
    end
  end


  context "Country Codes" do
    it "should be CN" do
      PatentAgent::PatentNum.new("CN456505").country_code.should eq "CN"
    end

    it "should be AZ" do
      PatentAgent::PatentNum.new("az456505.B2").country_code.should eq "AZ"
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
      reissue.valid?.should be_true
    end

    it "should have a #number" do
      reissue.number.should eq "55434"
    end

    it "should have a US country code" do
      reissue.country_code.should eq "US"
    end

    it "should have a kind code" do
      reissue.kind.should eq ""
    end
  end
end