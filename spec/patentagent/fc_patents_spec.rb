require 'spec_helper'

module PatentAgent
  describe ForwardCitationPatents, :vcr do
    let(:parent)       {"US6266379"}
    let(:nums)         {["8,705,606", "8,681,837", "8,675,483", "8,665,940", "8,659,325", "8,654,573", "8,564,328", "8,311,147"]}
    subject(:fc)       {ForwardCitationPatents.new(parent, nums)}
    
    it          {should respond_to :parent, :names}
    its(:names) {should have(8).items }

    describe "protected methods" do
      it "#urls_from" do
        urls = fc.send(:urls_from, nums)
        urls.should have(nums.size).items
      end
    end
  end
end