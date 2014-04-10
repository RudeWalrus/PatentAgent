require 'spec_helper'

module PatentAgent
  describe Patent do
    subject(:patent) {Patent.new("US6262379")}

    context "#new" do
      it "defaults to USPTO object" do
        patent.authority.should eq(:pto)
      end
      it "constructs to EPO when chosen" do
        pat = Patent.new("US6262379", authority: :epo)
        pat.authority.should eq(:epo)
      end

      it {should be_valid}
      
      it "Given a string, it should return a valid patent" do
        pat = Patent.new("US6262379")
        expect(pat).to be_valid
      end

      it "Given a PatentNum, it should return a valid patent" do
        num = PatentNum.new("US6266379")
        pat = Patent.new(num)
        expect(pat).to be_valid
      end
    end
  end
end