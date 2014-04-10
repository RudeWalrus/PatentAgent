require 'spec_helper'

module PatentAgent
  describe PatentAgent do
    
    context "#validate_patent_numbers" do
      let(:all_good)  { %w[US5551212 6661113 us8081555.b1 Us7776655.A1] }
      let(:all_bad)   { %w[US9551212 661113 2081555.b1 b3] }

      it "accepts an array, returns array" do
        result = PatentAgent.validate_patent_numbers(all_good)
        expect(result).to be_kind_of(Array)
      end

      it "accepts a string, returns a string" do
        mixed = all_good + all_bad
        result = PatentAgent.validate_patent_numbers("US5551212")
        expect(result).to eq("US5551212")
        expect(result).to be_kind_of(String)
      end

      it "accepts several strings, returns array" do
        mixed = all_good + all_bad
        result = PatentAgent.validate_patent_numbers("US5551212", "6661113")
        expect(result).to include("US5551212", "6661113")
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

      it "list with commas" do
        inp  = %w[7,308,060 B1 7,342,942 B1 7,142,564 B1 7,369,574 B1 7,327,760 B1]
        out  = %w[7,308,060 7,342,942 7,142,564 7,369,574 7,327,760]
        result = PatentAgent.validate_patent_numbers(inp)
        expect(result).to eq(out)
      end

    end
  end
end