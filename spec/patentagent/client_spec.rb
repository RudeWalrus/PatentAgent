require 'spec_helper'

module PatentAgent
  
  describe "Ops/Base Url" do
    let(:patent)        {"US7139271"}
    subject(:family)    {OpsBiblioFamilyUrl.new(patent)}
    %w[to_url text job_id valid].each { |method|
      it "Responds to #{method}" do
        OpsBiblioFamilyUrl.new(patent).should respond_to method.to_sym
        PtoUrl.new(patent).should respond_to method.to_sym
      end
    }
  end

  describe Client, vcr: true do
    let(:patent)      {"US7139271"}
    #let(:patents)     {%w[US5551212 US6661212 US7771212 US8012345]}
    subject(:client)  {Client.new(patent)}
    
    context "#initialize"do
      it {should respond_to :run}

      its(:ops) {should be_a OpsBiblioFamilyUrl}
      its(:pto) {should be_a PtoUrl}
      
      %w[ops pto fc].each do |org|
        its(org.to_sym) {should respond_to :to_request}
        its(org.to_sym) {should respond_to :to_url}
      end

      context "PatentHydra" do
        its(:hydra) {should respond_to :run}
        its("hydra.hydra") {should be_a Typhoeus::Hydra}
      end
    end

    context "#run" do
      let(:xml)    {File.read(File.dirname(__FILE__) + "/../fixtures/US7139271.xml") }
      it "hits OPS and PTO" do
        pto = Typhoeus::Response.new(code: 200, body: "{'pto' : '#{patent}'}")
        ops = Typhoeus::Response.new(code: 200, body: xml)
        Typhoeus.stub(/ops\.epo\.org/).and_return(ops)
        Typhoeus.stub(/patft\.uspto\.gov/).and_return(pto)
        result = client.run
        expect(result).to be_kind_of Array
        expect(result).to have(2).items
      end

      it "hits the website" do
        result = Client.new("US7139271").run
        expect(result).to have(2).items
      end
    end
  end

  describe FamilyClient, vcr: true do
    let(:list)        {%w[7139271  7142564 7286566 7295574 7298738 7327760 7342942 7369574]}
    subject(:family)  {FamilyClient.new(list)}

    it "#results is array" do
      family.run
      family.results.should be_kind_of Array
      family.results.should have(8).items
    end
  end
end