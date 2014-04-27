require 'spec_helper'
require "patentagent/ops/fields"


module PatentAgent::OPS
  describe Fields do
    let(:num)           {"7139271"}
    let(:cc)            {"US"}
    let(:pnum)          {cc + num}
    let(:xml)           {File.read(File.dirname(__FILE__) + "/../../fixtures/#{pnum}.xml")}
    let(:node)          {Nokogiri::XML(xml).css("ops|family-member").first }
    subject(:fields)    {Fields.new(node)}
  
    it                {should be}
    it                {should respond_to :process, :keys}
    it                {should respond_to :title, :inventors, :issue_date, :references}
    its(:keys)        {should include :title, :inventors, :issue_date, :references}
    its("keys.size")  {should eq Fields.count}

    context "#process" do
      before(:all) {fields.process}
      # %w[:title :inventors :issue_date :references].each do |key|
      #   it "has valid input for #{key}" do
      #     fields.should respond_to(key)
      #   end
      its(:patent_number)   {should eq "US7139271"}
      its(:title)       {should eq "Using an embedded indication of egress application type to determine which type of egress processing to perform"}
      its(:inventors)   {should eq ["PARRUCK BIDYUT[US]", "RAMAKRISHNAN CHULANUR[US]"]}
      its(:issue_date)  {should eq "20061121"}
      
      it "#classifications" do
        cls = fields.classifications.map{|h| h.values.inject(&:+)}
        cls.should include "H04L47621", "H04L125601", "H04L125602"
      end
      it "has correct priority" do
        fields.priority.should eq "20010207"
      end
      it "has correct application" do
        fields.applications[0][:date].should eq "20011012"
      end
    end
  end
end