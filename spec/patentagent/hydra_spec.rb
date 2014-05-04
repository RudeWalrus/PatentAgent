require 'spec_helper'

module PatentAgent
  describe Hydra, :vcr do
    let(:patent)      {"US7139271"}
    let(:pto)         {PtoClient.new(patent)}
    let(:ops)         {OpsBiblioFamilyClient.new(patent)}

    it                {Hydra.should respond_to :cache_size}
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

    describe "#fetch_single_item" do
      it "is right class" do 
        hydra = Hydra.new(PtoPatentClient.new("US7139271"))
        hydra.should be_kind_of Hydra
        hydra.fetch_single_item.should be_kind_of PtoPatentClient
      end
    end
  end
  
end