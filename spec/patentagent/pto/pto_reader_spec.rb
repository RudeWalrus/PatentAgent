require 'spec_helper'

module PatentAgent
  module PTO
    describe PTOReader, vcr: true do
      let(:num)         {"US6266379"}
      let(:patent)      {PatentNumber.new(num)}
      subject(:reader)  {PTOReader.new(patent)}
      
      context "self.read" do
        it "gets valid patent from file" do
          data = PTOReader.read(patent)
          expect(data).to be_kind_of(String)
        end
      
        it "should return nil from #read on http error" do
          RestClient.stub(:get).and_raise("HTTP Error")
          PTOReader.read(patent).should be_nil
        end
      end
      
      describe "urls" do
        let(:num) {"6266379"}
        let(:pnum) {PatentNumber.new(num)}

        it "Generates a US url" do
          path = "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO1&Sect2=HITOFF&d=PALL&p=1&u=/netahtml/PTO/srchnum.htm&r=1&f=G&l=50&s1=6266379.PN.&OS=PN/6266379&RS=PN/6266379"
          PTOReader.patent_url(pnum).should eq path
        end

        it "generates a forward citation url" do
          url = PTOReader.fc_url(pnum, 3)
          url.should match /ref\/#{num}/
          url.should match /p=3/
        end
      end
    end
  end
end