require 'spec_helper'


module PatentAgent

  describe Dispatcher do
    let(:patents)         {%w[US5551212 US6661212 US7771212 US8012345]}
    subject(:dispatcher)  {Dispatcher.new(*patents)}
   
      context "inputs" do
        it "Takes many args" do
          disp = Dispatcher.new(*patents)
          disp.list.should be_kind_of Array
          disp.list.size.should eq 4
        end

        it "Takes an array" do
          disp = Dispatcher.new(patents)
          dispatcher.list.should be_kind_of Array
          disp.list.size.should eq 4
        end
      end

      its(:results)     {should be_kind_of Array}

  end

end