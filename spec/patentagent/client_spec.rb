require 'spec_helper'

module PatentAgent
  
  describe "Client" do
    let(:patent)        {"US7139271"}
    subject             {Client.new(patent)}

    %w[to_url text job_id to_patent].each { |method|
        it {should respond_to method.to_sym}
    }
  end
end