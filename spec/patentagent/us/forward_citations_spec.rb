require 'spec_helper'

describe PatentAgent::Patent do
  let(:num)         {"US5539735"}
  let(:pnum)        {PatentAgent::PatentNum.new(num)}
  let(:html)        {File.read(File.dirname(__FILE__) + "/../../fixtures/#{num}_fc" + '.html') }
  subject(:patent)  {PatentAgent::ForwardCitation.new(pnum)}
  
  context "#new" do
    it "constructs from a string" do
      obj = PatentAgent::ForwardCitation.new("US5539735")
      obj.should be
    end

    it "constructs from a PatentNum" do
      obj = PatentAgent::ForwardCitation.new(pnum)
      expect(obj).to be 
    end
  end

  context "internal methods" do
    [5,10,50,200,1000].each do |cnt|
      it "Calculates the right number of references for #{cnt}" do
        this_page = cnt < 50 ? cnt : 50
        hits = "hits 1 through #{this_page} out of #{cnt}"
        PatentAgent::USClient.stub(:get_from_url).and_return(hits)
        patent.get_fc_html
        patent.count.should == cnt
        patent.pages.should == (cnt.to_f / 50.0).ceil
      end
    end
  end

  context "Gets forward citations" do
    before {PatentAgent::USClient.stub(:get_from_url).and_return(html)}

    it {should_not be_valid}
    
    it "Gets the html for a patents forward references" do
      patent.get_fc_html
      patent.should be_valid
    end

    it "get the correct count of forward references" do
      patent.get_fc_html
      patent.count.should eq 297
    end

    it "get the correct number of pages" do
      patent.get_fc_html
      patent.pages.should eq 6
    end

    context "Getting references" do
      it "fc_references has 50 patents" do
        patent.get_fc_html
        patent.parse_fc_html
        patent.fc_references.should have(50).items
      end
    end
  end

  context "fetches all the forward reference" do
    it "gets all references" do
      patent.fetch_forward_references
      patent.count.should == 297
      patent.fc_references.size.should == 297
    end
  end
end