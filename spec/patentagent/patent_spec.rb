require 'spec_helper'
require 'typhoeus'

module PatentAgent
  describe Patent do
    #PatentAgent.debug = true
    let(:number)     {"7139271"}
    let(:pnum)       {"US" + number}
    subject(:patent) {Patent.new(pnum)}

    describe "#initialize", :vcr do
      it {should be_kind_of Patent}
      it {should respond_to :number, :cc, :kind}
      it {should respond_to :patent, :results, :family, :pto, :fc, :claims}
      its(:family) {should be_kind_of Array}
      its(:number) {should eq number}
      its(:cc) {should eq "US"}

      context "Gets a family" do
        it "family#size" do
          patent.family.size.should eq 9
        end
      end
      
      it "has claims" do
        patent.should have(11).claims
        patent.claims.should be_kind_of Hash
        1.upto(11) { |i| patent.claims[i].should be_kind_of Hash }
      end

      it "rationalizes common fields" do
        patent.rationalize
      end
      
    end
  end
end