require 'spec_helper'
require "patentagent/ops/fields"


module PatentAgent::OPS
  describe Fields do
    let(:num)           {"7139271"}
    let(:cc)            {"US"}
    let(:pnum)          {cc + num}
    let(:xml)          {File.read(File.dirname(__FILE__) + "/../../fixtures/#{pnum}.xml") }
    subject(:fields)    {Fields.new(xml)}
  
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
      its(:title)       {should eq "Multi-service segmentation and reassembly device with a single data path that handles both cell and packet traffic"}
      its(:inventors)   {should eq ["PARRUCK BIDYUT[US]", "RAMAKRISHNAN CHULANUR[US]"]}
      its(:issue_date)  {should eq "20061128"}

      its(:classification)  {should include "H04L47621", "H04L125601", "H04L125602"}
      it "has correct priority" do
        fields.priority[:date].should eq "20010207"
        fields.priority[:doc_number].should eq "US20010779381"
      end
      it "has correct application" do
        fields.application[:date].should eq "20011012"
      end
    end
  end
end