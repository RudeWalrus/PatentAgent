require 'spec_helper'

module PatentAgent
  describe Patent do
    let(:number)     {"7139271"}
    let(:pnum)       {"US" + number}
    subject(:patent) {Patent.new(pnum)}

    describe "#initialize", vcr: true do
      it {should be_kind_of Patent}
      its(:patent) {should be_kind_of Hash}
      its(:family) {should be_kind_of Array}
      its(:number) {should eq number}
      its(:cc) {should eq "US"}

      it "gets a family" do
        patent.family.size.should eq 9
      end

      it "has claims" do
        patent.claims.count.should eq 11
        patent.claims.should be_kind_of Hash
        1.upto(11) { |i| patent.claims[i].should be_kind_of Hash }
      end
      
    end
  end
end