require 'spec_helper'

describe PatentAgent::PTO do
    let(:patent)  {"US6266379"}
    let(:html) { File.read(File.dirname(__FILE__) + "/../../fixtures/#{patent}" + '.html') }
    
    context "Validate Patent Numbers" do
      it "should parse a valid patent number passed as string with commas" do
        num = ",266,379"
        [4,5,6,7,8].each do |prefix|
          base = "#{prefix}#{num}"
          base_cmp = base.delete ','
          PatentAgent::PTO.valid_patent_number?(base).should == base_cmp
          PatentAgent::PTO.valid_patent_number?("US#{base}").should == base_cmp
          PatentAgent::PTO.valid_patent_number?("US#{base}.B1").should == base_cmp
          PatentAgent::PTO.valid_patent_number?("US#{base}.B2").should == base_cmp
        end
      end
    
      it "should parse a valid patent number passed as string without commas" do
        num = "266379"
        [4,5,6,7,8].each do |prefix|
          base = "#{prefix}#{num}"
          PatentAgent::PTO.valid_patent_number?(base).should == base
          PatentAgent::PTO.valid_patent_number?("US#{base}").should == base
          PatentAgent::PTO.valid_patent_number?("US#{base}.B1").should == base
          PatentAgent::PTO.valid_patent_number?("US#{base}.B2").should == base
        end
      end
    
      it "should parse a ReIssue (RE) patent number" do
        num = "266379"
        %w[RE55571 RE23234 Re33333].each do |re|
          PatentAgent::PTO.valid_patent_number?(re).should == re
        end
      end
      it "should parse a valid patent number passed as int" do
        num = "266379"
        [4,5,6,7,8].each do |prefix|
          base = "#{prefix}#{num}".to_i
          PatentAgent::PTO.valid_patent_number?(base).should == base.to_s
        end
      end
    
      it "should catch an invalid patent number(bad prefix)" do
        PatentAgent::PTO.valid_patent_number?("3234343").should  be_nil
      end
    
      it "should catch an invalid patent number (too short)" do
         PatentAgent::PTO.valid_patent_number?("3234343").should be_nil
      end
    
      it "should catch an invalid patent number (too long)" do
        PatentAgent::PTO.valid_patent_number?("62343430").should  be_nil
      end
    end
    
    context "Get HTML" do
  
      it "should #get_html with valid patent from file" do
        PatentAgent::PTO.stub(:get_from_url).and_return(html)
        data = PatentAgent::PTO.get_html(patent)
        data.should be
      end
    
      it "should return nil from #get_html on http error" do
        RestClient.stub(:get).and_raise("HTTP Error")
        PatentAgent::PTO.get_html(patent).should be_nil
      end
      
      # it "should return html from #get_html on live read" do
      #         PatentAgent::PTO.get_html(patent).should be
      #       end
    end
end