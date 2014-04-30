require "spec_helper"

module PatentAgent::OPS

  describe OpsPatent, vcr: true do
    let(:num)         {"US7139271"}
    let(:xml)         {Reader.get_family(num, auth: false)}
    subject(:patent)  {OpsPatent.new(num, xml)}
  
    before do
      ENV["OPS_CONSUMER_KEY"] = "1KDu067AJUlnCB0GLzJSC1ookqNxxZOn"
      ENV["OPS_SECRET_KEY"]   = "rRBKrsBaoOzWZ99G"
    end

    its(:family)    {should be_kind_of(Array)}
    its(:family_members)   {should be_kind_of(Array)}
    its(:family_members)   {should include("US7139271.B1", "US7286566.B1")}
    its(:to_a)        {should be_kind_of Array}
    its("to_a.size")  {should eq 9}
    its(:target)      {should be_kind_of Hash}
    
    it "#to_a" do
      patent.to_a.should be_kind_of Array
      patent.to_a.size.should eq 9
      9.times {|x| 
        patent.to_a[x][:inventors].should satisfy {|x| x.grep "PARRUCK BIDYUT"}
        patent.to_a[x].should be
    }
    end

    it "Finds correct number of family members" do
      patent.family.should be_kind_of Array
      patent.family.size.should eq 9
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
