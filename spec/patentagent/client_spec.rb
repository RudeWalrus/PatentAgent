require 'spec_helper'

module PatentAgent
  describe PatentHydra, vcr: true do
    let(:patent)      {"US7139271"}
    let(:pto)         {PtoUrl(patent)}
    let(:ops)         {OpsBiblioFamilyUrl.new(patent)}

    context "OPS" do
      before :all do
        hydra = PatentHydra.new(ops)
        @res = (hydra.run)[0]
      end
      it "gets xml" do
        @res.text.should match patent
      end
    end
  end

  describe Client do
    let(:patent)      {"US7139271"}
    #let(:patents)     {%w[US5551212 US6661212 US7771212 US8012345]}
    subject(:client)  {Client.new(patent)}
    
    context "#initialize"do
      it {should respond_to :run}

      its(:ops) {should be_a OpsBiblioFamilyUrl}
      its(:pto) {should be_a PtoUrl}

      its(:pto) {should respond_to :request}
      its(:pto) {should respond_to :to_url}
      its(:ops) {should respond_to :to_url}
      its(:ops) {should respond_to :request}

      context "PatentHydra" do
        its(:hydra) {should respond_to :run}
        its("hydra.hydra") {should be}
        its("hydra.hydra") {should be_a Typhoeus::Hydra}
      end
    end

    context "#run", vcr: true do
      it "hits OPS and PTO" do
        pto = Typhoeus::Response.new(code: 200, body: "{'pto' : '#{patent}'}")
        ops = Typhoeus::Response.new(code: 200, body: "{'ops' : '#{patent}'}")
        Typhoeus.stub(/ops\.epo\.org/).and_return(ops)
        Typhoeus.stub(/patft\.uspto\.gov/).and_return(pto)
        result = client.run
        expect(result).to be_kind_of Array
        expect(result).to have(2).items
        p result[0]
        p result[1]
      end

      it "hits the website" do
        client = Client.new("US7139271")
        result = client.run
        expect(result).to have(2).items
        expect(result[0].text).to match /7139271/
        p result[0].text
      end
    end
  end
end