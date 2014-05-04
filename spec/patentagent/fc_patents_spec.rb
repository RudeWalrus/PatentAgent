require 'spec_helper'

module PatentAgent
  describe ForwardCitationPatents, :vcr do
    let(:num)         {"US5539735"}
    let(:pnum)        {PatentNumber.new(num)}
    let(:fc)          {ForwardCitations.new(pnum)}
    subject(:patents) {ForwardCitationPatents.new(pnum, fc)}
    
    it          {should respond_to :parent, :names}
    its(:names) {should have(324).items }
  end
end