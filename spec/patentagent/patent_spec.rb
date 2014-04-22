require 'spec_helper'

module PatentAgent
  describe Patent do
    let(:number)     {"8031234"}
    let(:pnum)       {"US" + number}
    subject(:patent) {Patent.new(pnum)}

    context "#initialize" do
      it "class is Patent" do
        expect(patent).to be_kind_of(Patent)
      end

      it "contructs from string" do
        expect(patent).to be_valid
        expect(patent.number).to eq(number)
      end

      it "contructs from PatentNumber" do
        num = PatentNumber.new(pnum)
        pat = Patent.new(num)
        expect(pat).to be_valid
      end

      it "delegates number to PatentNumber" do
        expect(patent.number).to eq(number)
      end


      [:number, :title, :abstract, :assignees, :inventors, :filed].each do |field|
        it "responds to ##{field}" do
          expect(patent).to respond_to(field)
        end
      end

      it "defaults to USPTO object" do
        patent.authority.should eq(:pto)
      end
      
      it "constructs to EPO when chosen" do
        pat = Patent.new(pnum, authority: :epo)
        pat.authority.should eq(:epo)
      end

      it "given a PatentNum, returns a valid patent" do
        num = PatentNumber.new(pnum)
        pat = Patent.new(num)
        expect(pat).to be_valid
      end

      it "returns invalid for bogus patent number" do
        num = Patent.new("US555")
        expect(num).to_not be_valid
      end
    end

    context "#fetch", vcr: true do
      before {patent.fetch}
    
      it "returns valid #title" do
        expect(patent.title).to eq("Imaging apparatus and method for driving imaging apparatus")
      end
      it "returns valid #inventors" do
        expect(patent.inventors).to include("Wada; Tetsu")
      end
      it "returns valid #assignees" do
        expect(patent.assignees).to include("Fujifilm Corporation")
      end
    end
  end
end