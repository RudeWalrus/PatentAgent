require 'spec_helper'
require "patentagent/ops/fields"


module PatentAgent::OPS
  describe Fields do
    let(:num)           {"7139271"}
    let(:cc)            {"US"}
    let(:pnum)          {cc + num}
    let(:xml)           {File.read(File.dirname(__FILE__) + "/../../fixtures/#{pnum}.xml")}
    let(:node)          {Nokogiri::XML(xml).css("ops|family-member").first }
    let(:f)             {Fields}
    subject(:fields)    {Fields.new(node)}
  
    it                {should be}
    it                {should respond_to :keys}
    it                {should respond_to :title, :inventors, :issue_date, :references}
    its(:keys)        {should include :title, :inventors, :issue_date, :references}
    its("keys.size")  {should eq f.count}
    its(:to_h)        {should be_kind_of Hash}
    its("to_h.size")  {should eq f.count}
 
    its(:number)       {should eq "US7139271"}
    its(:title)       {should eq "Using an embedded indication of egress application type to determine which type of egress processing to perform"}
    its(:inventors)   {should eq ["PARRUCK BIDYUT[US]", "RAMAKRISHNAN CHULANUR[US]"]}
    its(:issue_date)  {should eq "20061121"}
    
    it "#classifications" do
      cls = fields.classifications.map{|h| h[:full]}
      cls.should include "H04L47/621", "H04L12/5601", "H04L12/5602"
    end
    it "has correct priority" do
      fields.priority.should eq "20010207"
    end
    it "has correct application" do
      fields.applications[0][:date].should eq "20011012"
    end
    
    it "#issued?" do
      fields.should be_issued
    end

    describe "#to_h" do
      let(:hash) {fields.to_h}
      Fields.keys.each {|key|
        it "Has data for :#{key}" do
          hash[key].should_not be_empty
        end
      }
    end
  end
end