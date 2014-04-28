require 'spec_helper'
require "patentagent/ops/ops_fields"


module PatentAgent::OPS
  describe OPSFields do
    let(:num)           {"7139271"}
    let(:cc)            {"US"}
    let(:pnum)          {cc + num}
    let(:xml)           {File.read(File.dirname(__FILE__) + "/../../fixtures/#{pnum}.xml")}
    let(:node)          {Nokogiri::XML(xml).css("ops|family-member").first }
    subject(:fields)    {OPSFields.new(node)}
  
    it                {should be}
    it                {should respond_to :keys}
    it                {should respond_to :title, :inventors, :issue_date, :references}
    its(:keys)        {should include :title, :inventors, :issue_date, :references}
    its("keys.size")  {should eq OPSFields.count}
    its(:to_hash)     {should be_kind_of Hash}
    its("to_hash.size")     {should eq OPSFields.count}
 
    its(:patent_number)   {should eq "US7139271"}
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
    
    describe "#to_hash" do
      before {@hash = fields.to_hash}
      OPSFields.keys.each {|key|
        it "creates field for :#{key}" do
          @hash[key].should be
        end
      }
    end
  end
end