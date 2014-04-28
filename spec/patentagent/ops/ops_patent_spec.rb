require "spec_helper"

module PatentAgent::OPS

  describe OpsPatent, vcr: true do
    let(:num)      {"US7139271"}
    subject(:patent)  {OpsPatent.new(num)}
  
    before do
      ENV["OPS_CONSUMER_KEY"] = "1KDu067AJUlnCB0GLzJSC1ookqNxxZOn"
      ENV["OPS_SECRET_KEY"]   = "rRBKrsBaoOzWZ99G"
    end

    its(:cache)     {should be_kind_of(Hash)}
    its(:family)    {should be_kind_of(Array)}
    its(:family_members)   {should be_kind_of(Array)}
    its(:family_members)   {should include("US7139271.B1", "US7286566.B1")}
    its(:to_a)        {should be_kind_of Array}
    its("to_a.size")  {should eq 9}
    
    it "Finds correct number of family members" do
      patent.family.count.should eq 9
    end

    it "Has the right title for primary patent" do
      patent.title.should match "Using an embedded indication of egress application"
    end
    it "Has the right inventors for primary patent" do
      patent.inventors.should include "PARRUCK BIDYUT[US]", "RAMAKRISHNAN CHULANUR[US]"
    end

    it "data for any family member" do
      patent.to_a.each { |item| item.should include(:title, :assignees, :issue_date, :applications) }
    end

    
  end
end
