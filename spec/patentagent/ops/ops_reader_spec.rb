require "spec_helper"
require "timecop"

module PatentAgent::OPS

  describe Reader::OAuth, vcr: true do
    let(:id)      {"1KDu067AJUlnCB0GLzJSC1ookqNxxZOn"}
    let(:secret)  {"rRBKrsBaoOzWZ99G"}

    it "fetches a bearer token"  do
      token = Reader::OAuth.request_token(id, secret)
      expect(token).to_not be_nil
      expect(token).to match /\w+/
    end

    describe "Expires token" do
      before  {Timecop.freeze(Time.now)}
      after   {Timecop.return}
      it "reuses token if time is less than 20 minutes" do
        #Reader::OAuth.should_receive(:get_token)
        Reader::OAuth.request_token(id, secret)
        Timecop.travel(Time.now + 600)  # 10 minutes in the future
        Reader::OAuth.request_token(id, secret)
      end
      it "gets new token if time is greater than 20 minutes" do 
        #Reader::OAuth.should_receive(:get_token).exactly(2).times
        Reader::OAuth.request_token(id, secret)
        Timecop.travel(Time.now + 1201) #20m + 1 sec in the future
        Reader::OAuth.request_token(id, secret)
      end
    end
  end

  describe Reader, vcr: true do
    it "gets family biblio" do
      node = Reader.get_family("US7139271", auth: false)
      node.should be_kind_of String
    end

    it "gets called with auth enabled" do
      Reader::OAuth.stub(:get_token).and_return("Valid Token")
      Reader.should_receive(:get_xml).with(/biblio/, /US/, hash_including(auth: true))
      Reader.get_family("US7139271", auth: true)
    end
  end
end