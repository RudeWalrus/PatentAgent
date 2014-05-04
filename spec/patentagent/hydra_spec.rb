require 'spec_helper'

module PatentAgent
  describe Hydra, vcr: true do
    let(:patent)      {"US7139271"}
    let(:pto)         {PtoClient.new(patent)}
    let(:ops)         {OpsBiblioFamilyClient.new(patent)}

    context "OPS" do
      let(:hydra)     {Hydra.new(ops)}
      subject(:res)   {(hydra.run)[0]}

      its(:text)        {should match patent}
      its("patent.full")    {should match patent}

      it "Gives the right xml" do
        nodes = Nokogiri::XML(res.text)
        nodes.should be_kind_of Nokogiri::XML::Document
      end
    end
  end
  
end