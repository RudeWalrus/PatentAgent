require 'spec_helper'
require 'typhoeus'
require "pp"

module PatentAgent
  describe "live testing"  do
    #PatentAgent.debug = true
    let(:number)     {"7139271"}
    let(:pnum)       {"US" + number}
    subject(:patent) {Patent.new(pnum)}

    before { VCR.eject_cassette; VCR.turn_off!}
    #pat = Patent.new("US6266379")
    #pp pat.ops.family_issued
    #pp pat.to_h
    #pp pat.fc
  end
end