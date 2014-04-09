require 'spec_helper'

module PatentAgent
  describe Patent do
    context "#new" do
      it {should_not be_valid}
      
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