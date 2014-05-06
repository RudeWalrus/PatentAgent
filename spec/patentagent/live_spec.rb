require 'spec_helper'
require 'typhoeus'
require "pp"

module PatentAgent
  describe "live testing"  do
    #PatentAgent.debug = true
    #let(:number)     {"7139271"}
    let(:number)     {"7141214"}
    let(:pnum)       {"US" + number}
    subject(:patent) {Patent.new(pnum)}

    # before { VCR.eject_cassette; VCR.turn_off!}
    # PatentAgent.debug = true
    # pat = Patent.new("7141214")
    # #pp pat.ops.family_issued
    # pp pat.pto
    # #pp pat.fc
    # #pp pat.ops
  end
end