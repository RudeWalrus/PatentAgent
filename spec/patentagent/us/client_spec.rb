require 'spec_helper'

describe PatentAgent::USClient do
  let(:num)     {"US6266379"}
  let(:patent)  {PatentAgent::PatentNum.new(num)}
  let(:html)    {File.read(File.dirname(__FILE__) + "/../../fixtures/#{num}" + '.html') }
  let(:url)     {PatentAgent::USUrls.patent_url(patent)}
  
  context "Get HTML" do

    it "should #get_html with valid patent from file" do
      PatentAgent::USClient.stub(:get_from_url).and_return(html)
      data = PatentAgent::USClient.get_html(patent, url)
      data.should be
    end
  
    it "should return nil from #get_html on http error" do
      RestClient.stub(:get).and_raise("HTTP Error")
      PatentAgent::USClient.get_html(patent,url).should be_nil
    end
  end
end