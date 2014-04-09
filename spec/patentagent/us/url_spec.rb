require 'spec_helper'

module PatentAgent
  describe USUrls do
    let(:num) {"6266379"}
    let(:pnum) {PatentNum.new(num)}

    context "Private Methods" do 
      it "Returns the number part of a patent" do
        number = USUrls.send(:get_num_part_of_patent, pnum)
        number.should == num
      end
      it "Accepts a string & returns the number part of a patent" do
        number = USUrls.send(:get_num_part_of_patent, "US#{pnum}")
        number.should == num
      end
    end



    it "Generates a US url" do
      path = "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO1&Sect2=HITOFF&d=PALL&p=1&u=/netahtml/PTO/srchnum.htm&r=1&f=G&l=50&s1=6266379.PN.&OS=PN/6266379&RS=PN/6266379"
      USUrls.patent_url(pnum).should eq path
    end

    it "generates a forward citation url" do
      url = USUrls.fc_url(pnum, 3)
      url.should match /ref\/#{num}/
      url.should match /p=3/
    end
  end
end