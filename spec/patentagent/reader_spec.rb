require 'spec_helper'

module PatentAgent
  describe Reader, vcr: true do
    let(:num)         {"US6266379"}
    let(:patent)      {PatentNumber.new(num)}
    let(:url)         {USPTO::URL.patent_url(patent)}
    subject(:reader)  {Reader.new(patent, url)}
    
    context "self.get_html" do
      it "gets valid patent from file" do
        data = Reader.get_html(patent, url)
        expect(data).to be_kind_of(String)
      end
    
      it "should return nil from #get_html on http error" do
        RestClient.stub(:get).and_raise("HTTP Error")
        Reader.get_html(patent,url).should be_nil
      end
    end
  end
end