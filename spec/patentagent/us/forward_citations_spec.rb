require 'spec_helper'

module PatentAgent
  module USPTO
    describe ForwardCitation do
      let(:num)         {"US5539735"}
      let(:pnum)        {PatentNum.new(num)}
      subject(:patent)  {ForwardCitation.new(pnum)}
    
      context "#new" do
        it "constructs from a string" do
          expect(patent).to be 
        end
        it "constructs from a PatentNum" do
          expect(pnum).to be
        end
      end

      context "internal methods" do
        [5,10,50,200,1000].each do |cnt|
          it "Calculates the right number of references for #{cnt}" do
            this_page = cnt < 50 ? cnt : 50
            hits = "hits 1 through #{this_page} out of #{cnt}"
            Client.stub(:get_html).and_return(hits)
            patent.fetch
            expect(patent.count).to eq cnt
            expect(patent.pages).to eq (cnt.to_f / 50.0).ceil
          end
        end
      end

      context "Gets forward references", vcr: true do
        it "invalid before fetch" do
          expect(patent).to_not be_valid
        end

        it "fetches all forward references for US5539735" do
          patent.fetch
          patent.should be_valid
          patent.count.should eq 321
          patent.pages.should eq 7
          patent.fc_references.should have(321).items
        end
      end
    end
  end
end
  