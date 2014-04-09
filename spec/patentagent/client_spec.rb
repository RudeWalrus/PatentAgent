require 'spec_helper'

module PatentAgent
  describe Client, vcr: true do
    let(:num)     {"US6266379"}
    let(:patent)  {PatentNum.new(num)}
    let(:url)     {USPTO::URL.patent_url(patent)}
    subject(:client)  {Client.new(patent, url)}
    
    context "self.get_html" do
      it "gets valid patent from file" do
        data = Client.get_html(patent, url)
        expect(data).to be_kind_of(String)
      end
    
      it "should return nil from #get_html on http error" do
        RestClient.stub(:get).and_raise("HTTP Error")
        Client.get_html(patent,url).should be_nil
      end
    end
  end
end