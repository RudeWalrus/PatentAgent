require "spec_helper"

module PatentAgent::OPS

  describe OpsPatent, vcr: true do
    let(:number)  {"7139271"}
    let(:pnum)       {"US" + number}
    subject(:patent) {OpsPatent.new(pnum)}
  
    before do
      ENV["OPS_CONSUMER_KEY"] = "1KDu067AJUlnCB0GLzJSC1ookqNxxZOn"
      ENV["OPS_SECRET_KEY"]   = "rRBKrsBaoOzWZ99G"
      patent.process
    end

    it "Creates a new object" do
      expect(patent).to be_valid
    end

    it "#process" do
      expect(patent).to be_valid
    end

    it "has 8 family members" do
      expect(patent.document[:family].count).to eq(9)
    end

  end

end
