require 'spec_helper'

describe PatentAgent::Patent do
  let(:num) {"US6266379"}
  let(:pnum)  {PatentAgent::PatentNum.new(num)}
  let(:patent) {PatentAgent::ForwardCitation.new(pnum)}
  
  describe "Gets a forward citation" do
    
    it "Gets the html for a patents forward references" do
      patent.get_fc_html
      patent.should be_valid
    end
  end
end