require 'spec_helper'

module PatentAgent
  describe PatentAgent do
    
    context "#validate_patent_numbers" do
      let(:all_good)  { %w[US5551212 6661113 us8081555.b1] }
      let(:all_bad)   { %w[US9551212 661113 2081555.b1 b3] }

      it "returns an array" do
        result = PatentAgent.validate_patent_numbers(all_good)
        expect(result).to be_kind_of(Array)
      end

      it "accepts good array list" do
        result = PatentAgent.validate_patent_numbers(all_good)
        expect(result).to eq(all_good)
      end

      it "rejects bad array list" do
        result = PatentAgent.validate_patent_numbers(all_bad)
        expect(result).to be_empty
      end

      it "returns only good values" do
        mixed = all_good + all_bad
        result = PatentAgent.validate_patent_numbers(mixed)
        expect(result).to eq(all_good)
      end
    end
  end
end