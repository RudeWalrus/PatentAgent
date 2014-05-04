require "spec_helper"
require 'patentagent/ops/ops_family'
require 'nokogiri'

module PatentAgent::OPS

  describe OpsFamily, vcr: true do
    let(:num)         {"US7139271"}
    let(:xml)         {File.read(File.dirname(__FILE__) + "/../../fixtures/US7139271.xml") }
    subject(:patent)  {OpsFamily.new(num, xml)}

    it            {should respond_to :members, :first, :[], :names }
    its(:members) {should be_a Array}
    its(:members) {should have(9).items}

    it "#members returns an Array of OpsFields" do
      patent.members.should be_all {|x| x.is_a? Fields }
    end

    it "#[]" do
      patent[0].should == patent.first
    end

    it "#names" do
      patent.names.should be_kind_of Array
      patent.should have(9).names
      patent.names.should be_all {|x| x.is_a? String }
    end

    its(:family_id) {should eq "37423271"}

    it "#map" do
      nums = %w[ US7139271  US2004062261  US7342942  US7298738  US7369574  US7286566  US7327760  US7295574  US7142564 ]
      arr = patent.map{|x| x.patent_number }
      arr.should eq nums
    end

  end
end
  