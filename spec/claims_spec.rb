require 'spec_helper'

def parse_claims text
    
  claim_text = text[/(?:Claims<\/b><\/i><\/center> <hr>)(.*?)(?:<hr>)/mi]

  # lets get the individual claims
  m = claim_text.scan( /<br><br>\s*(\d+\..*?)((?=<br><br>\s*\d+\.)|(?=<hr>))/mi)


  # collect the claims into an array
  parsed_claims = m.map { |x| x[0].gsub("\n", " ").gsub(/<BR><BR>/, " ") }
end


describe PatentAgent::Claims do
  
  let(:claims)  {PatentAgent::Claims.new}
  let(:claim_text) {File.read(File.dirname(__FILE__) + "/fixtures/US6266379.html") }

  describe '#new' do
    it "#initialize an empty class" do
      expect(claims.count).to         eq 0
      expect(claims.dep_count).to     eq 0
      expect(claims.indep_count).to   eq 0
      expect(claims.total).to         eq 0
      expect(claims.dep_claims).to    eq []
      expect(claims.indep_claims).to  eq []
    end
  end
    
  context "Reads in claims appropriately" do
    before do
      claim_array = parse_claims claim_text
      claim_array.each { |x| claims << x}
    end

    it "has the right count" do  
      expect(claims.count).to         eq 41
      expect(claims.total).to         eq 41
    end

    it "has the right # of dep claims" do
      expect(claims.dep_count).to     eq 29
    end

    it "has the right # of indep claims" do
      expect(claims.indep_count).to   eq 12
    end
     
    it "identifies the correct dep claims" do
      expect(claims.dep_claims).to    eq [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 30, 31, 32, 35, 37]
    end

    it "indetifies the correct indep claims" do 
      expect(claims.indep_claims).to  eq [1, 13, 17, 18, 29, 33, 34, 36, 38, 39, 40, 41]
    end
  end
end