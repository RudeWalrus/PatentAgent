require 'spec_helper'

module PatentAgent
  module PTO
    describe PTOReader, vcr: true do
      let(:num)         {"US6266379"}
      let(:patent)      {PatentNumber.new(num)}

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
 
        %w[US6266379 6266379].each do |num|
          it "generates correct uspto url" do
            path = "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO1&Sect2=HITOFF&d=PALL&p=1&u=/netahtml/PTO/srchnum.htm&r=1&f=G&l=50&s1=6266379.PN.&OS=PN/6266379&RS=PN/6266379"
            PTOReader.send(:patent_url, num).should eq path
          end

          it "generates correct uspto forward citation url" do
            url = PTOReader.send(:fc_url, num, 3)
            url.should match /ref\/6266379/
            url.should match /p=3/
          end
        end
      end
    end
  end
end