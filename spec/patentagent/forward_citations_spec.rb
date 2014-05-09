require 'spec_helper'

module PatentAgent

  describe ForwardCitations do
    let(:num)         {"US7139271"}
    let(:pnum)        {PatentNumber.new(num)}
    let(:html)        {File.read(File.dirname(__FILE__) + "/../fixtures/#{pnum}_fc.html")}
    subject(:patents)  {ForwardCitations.new(pnum, html)}
  
    describe "#new", :vcr do
      #PatentAgent.loud
      it {should respond_to :parent}
      it {should have(31).items }
      it {patents.pages.should eq 1}
    end

    describe "internal methods" do
      before {
        ForwardCitations.any_instance.stub(:fetch_remainder_from).and_return(true)
      }
      [1, 5,10,50,200,1000].each do |cnt|
        it "Calculates the right number of references for #{cnt}" do
          this_page = cnt < 50 ? cnt : 50
          hits = "hits 1 through #{this_page} out of #{cnt}"
          ForwardCitations.any_instance.stub(:fetch_first_page).and_return(hits)
          f = ForwardCitations.new(pnum, hits)
          expect(f.pages).to eq (cnt.to_f / 50.0).ceil
        end
      end

      it "Works for no forward citations" do
        hits = "No patents have matched your query"
        ForwardCitations.any_instance.stub(:fetch_first_page).and_return(hits)
        f = ForwardCitations.new(pnum, hits)
        expect(f.pages).to eq 0
      end
    end

    
  end
end
  