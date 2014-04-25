require "spec_helper"

module PatentAgent::OPS

  describe Reader, vcr: true do
    let(:id)      {"1KDu067AJUlnCB0GLzJSC1ookqNxxZOn"}
    let(:secret)  {"rRBKrsBaoOzWZ99G"}

    it "fetches a bearer token"  do
      token = Reader.get_oauth_token(id, secret)
      expect(token).to_not be_nil
      expect(token).to match /\w+/
    end
  end
end