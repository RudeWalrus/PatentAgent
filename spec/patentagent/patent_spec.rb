require 'spec_helper'

describe PatentAgent::Patent do
  context "#new" do
    it {should_not be_valid}
    
    it "Given a string, it should return a valid patent" do
      pat = PatentAgent::Patent.new("US6262379")
      expect(pat).to be_valid
    end
  end
end