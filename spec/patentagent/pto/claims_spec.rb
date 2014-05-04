require 'spec_helper'

module PatentAgent::PTO

  describe Claim do
    subject {Claim.new("1", "true", "Blah, blah, bla")}
    it  {should respond_to :parent, :dep, :text}
    it  {subject.to_h.should be_kind_of Hash}
  end
      
  describe Claims do
    let(:num)           {"6266379"}
    let(:pnum)          {"US" + num}
    let(:claim_text)    {File.read(File.dirname(__FILE__) + "/../../fixtures/#{pnum}.html") }
    subject(:claims)    {Claims.new(claim_text)}

      
    context "#initialize" do
      it  {should respond_to :total, :dep_count, :indep_count }
      it  {should respond_to :dep_claims, :indep_claims }
      
      it "has the right count" do  
        expect(claims.count).to         eq 41
        expect(claims.total).to         eq 41
      end

      it "has the right number of dep claims" do
        expect(claims.dep_count).to     eq 29
      end

      it "has the right number of indep claims" do
        expect(claims.indep_count).to   eq 12
      end
       
      it "identifies the correct dep claims" do
        expect(claims.dep_claims).to    eq [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 30, 31, 32, 35, 37]
      end

      it "indentifies the correct indep claims" do 
        expect(claims.indep_claims).to  eq [1, 13, 17, 18, 29, 33, 34, 36, 38, 39, 40, 41]
      end

      it "retrieves a Claim obj by index" do
        expect(claims[3]).to           be_kind_of(Claim)
      end

      it "retrieves a patent claim text by index" do
        expect(claims[3].text).to            match /3\.  A communication system as claimed in claim 1 wherein the equalizer converts/
      end

      it "retrieves a claims parent by index" do
        expect(claims[3].parent).to           eq(1)
        expect(claims[32].parent).to          eq(31)
      end

      it "retrieves a claims dep/indep state by index" do
        expect(claims[1].dep).to              be_false
        expect(claims[18].dep).to             be_false
        expect(claims[3].dep).to              be_true
        expect(claims[32].dep).to             be_true
      end
    end
  end

end