require "spec_helper"

module PatentAgent::OPS

  describe OpsPatent, vcr: true do
    let(:number)  {"7139271"}
    let(:pnum)       {"US" + number}
    subject(:patent) {OpsPatent.new(pnum)}
  

    it "Creates a new object" do
      expect(patent).to be_valid
    end

  end

end
