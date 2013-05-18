require 'spec_helper'

describe PatentAgent::USClient do
  let(:patent)  {PatentAgent::PatentNum.new("US6266379")}
  let(:html) { File.read(File.dirname(__FILE__) + "/../../fixtures/#{patent}" + '.html') }
  
  context "Get HTML" do

    it "should #get_html with valid patent from file" do
      PatentAgent::USClient.stub(:get_from_url).and_return(html)
      data = PatentAgent::USClient.get_html(patent)
      data.should be
    end
  
    it "should return nil from #get_html on http error" do
      RestClient.stub(:get).and_raise("HTTP Error")
      PatentAgent::USClient.get_html(patent).should be_nil
    end

    it "Should receive a valid path" do
      path = "http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO1&Sect2=HITOFF&d=PALL&p=1&u=/netahtml/PTO/srchnum.htm&r=1&f=G&l=50&s1=6266379.PN.&OS=PN/6266379&RS=PN/6266379"
      expect(PatentAgent::USClient.patent_url(patent)).to eq path
    end
    #         PatentAgent::PTO.get_html(patent).should be
    #       end
  end
end