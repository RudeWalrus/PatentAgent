require 'spec_helper'
require 'typhoeus'
require "pp"
require 'pry'

module PatentAgent
  describe "live testing"  do
    #PatentAgent.debug = true
    #let(:number)     {"7139271"}
    let(:number)     {"7141215"}
    let(:pnum)       {"US" + number}
    subject(:patent) {Patent.new(pnum)}

    before { VCR.eject_cassette; VCR.turn_off!}
    PatentAgent.debug = false
    #pat = Patent.new("6278783")
    #pat2 = Patent.new("7141214")
    #pp pat.ops.family_issued
    #pp pat.family_members.count
    # pp pat.ops.us_family_issued
    # pp pat.fc
    # pp pat.forward_citations.count
    # #pp pat.ops
  end
end