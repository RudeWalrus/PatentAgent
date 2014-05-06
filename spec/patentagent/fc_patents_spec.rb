require 'spec_helper'

module PatentAgent
  describe ForwardCitationPatents do
    let(:parent)       {"US6266379"}
    let(:nums)         {["8,705,606", "8,681,837", "8,675,483", "8,665,940", "8,659,325", "8,654,573", "8,564,328", "8,311,147"]}
    subject(:fc)       {ForwardCitationPatents.new(parent, nums)}
    
    it          {should respond_to :parent, :names}
    its(:names) {should have(8).items }

    describe "protected methods" do
      before {
        @clients = (0..7).collect{|x|PtoPatentClient.new(nums[x])}
        PatentAgent::Hydra.any_instance.stub(:run).and_return(@clients)
        @urls    = fc.send(:urls_from, nums)
        @texts   = fc.send(:text_from_urls, @urls)
      }

      it "#urls_from" do
        @urls.should have(nums.size).items
      end
  
      it "#text_from_urls" do
        @texts.should have(nums.size).items
        @texts.should be_all {|x| x.is_a? PtoClient}
      end

      it "#patent_from_text" do
        PatentAgent::PTO::PtoPatent.any_instance.stub(:parse).and_return(true)
        patents = fc.send(:patent_from_text, @texts)
        patents.should be_all {|x| x.is_a? PatentAgent::PTO::PtoPatent}
      end
    end
  end
end