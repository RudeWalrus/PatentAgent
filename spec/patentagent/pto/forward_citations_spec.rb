require 'spec_helper'

module PatentAgent
  module PTO
    describe ForwardCitation do
      let(:num)         {"US5539735"}
      let(:pnum)        {PatentNumber.new(num)}
      #let(:html)        {File.read(File.dirname(__FILE__) + "/../../fixtures/#{pnum}_fc.html")}
      subject(:patents)  {ForwardCitation.new(pnum)}
    
      context "#new", :vcr do
         it {should respond_to :names, :patents}
      end

      context "internal methods" do
        [5,10,50,200,1000].each do |cnt|
          it "Calculates the right number of references for #{cnt}" do
            this_page = cnt < 50 ? cnt : 50
            hits = "hits 1 through #{this_page} out of #{cnt}"
            ForwardCitation.any_instance.stub(:fetch_remainder_from).and_return(true)
            ForwardCitation.any_instance.stub(:fetch_first_page).and_return(hits)
            f = ForwardCitation.new(pnum)
            expect(f.count).to eq cnt
            expect(f.pages).to eq (cnt.to_f / 50.0).ceil
          end
        end
      end

      context "#fetch", :vcr do
        it "fetches all forward references" do
          patents.count.should eq 324
          patents.pages.should eq 7
          patents.names.should have(324).items
        end

        context "Private Methods", vcr: true, slow: true do
          it "#urls_from_names" do
            res = patents.send(:urls_from, patents.names)
            res.should be_kind_of Array
            res.size.should eq 324
            res[0].should be_kind_of PtoUrl
            res[-1].should be_kind_of PtoUrl
          end

          it "#html_from_urls" do
            names = patents.send(:urls_from, patents.names)
            htmls = patents.send(:html_from_urls, names)
            htmls.should be_kind_of Array
          end
      end
      end
    end
  end
end
  