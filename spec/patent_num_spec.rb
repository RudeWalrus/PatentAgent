require 'spec_helper'
require 'patentagent/patent_num'


describe PatentAgent::PatentNum do
  
  context "Basic Properties" do
  
    let(:patent) {PatentAgent::PatentNum.new("US7,267,263.B1") }
   
    it "Should return an object" do
      patent.should_not be_nil
    end

    it "should have a full number" do
      patent.full_number.should eq "US7267263.B1"
    end

    it "should be a #valid? object" do
      patent.valid?.should be_true
    end

    it "should have a #number" do
      patent.number.should eq "7267263"
    end

    it "should have a US country code" do
      patent.country_code.should eq "US"
    end

    it "should have a kind code" do
      patent.kind.should eq "B1"
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

    it "should have a full number" do
      reissue.full_number.should eq pnum
    end

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