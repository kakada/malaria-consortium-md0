require 'spec_helper'

describe VillageAlert do
  describe "source type" do
    before(:each) do
      @od = OD.create!
    end
    
    it "must be 'VillageAlert'" do
      alert = VillageAlert.create! :recipient_id => @od.id
      alert.source_type.should == "Village"
    end
  end
end