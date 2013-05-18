require 'spec_helper'

describe PatentAgent::Patent do
  let(:num) {"US6266379"}
  let(:pnum)  {PatentAgent::PatentNum.new(num)}
  let(:patent) {PatentAgent::ForwardCitation.new(pnum)}
  let(:html)    {File.read(File.dirname(__FILE__) + "/../../fixtures/#{num}_fc" + '.html') }
  
  describe "Gets a forward citation" do
    before {PatentAgent::USClient.stub(:get_from_url).and_return(html)}

    it "Gets the html for a patents forward references" do
      patent.get_fc_html
      patent.should be_valid
    end
  end
end