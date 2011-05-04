require 'spec_helper'

describe HealthCenterAlert do
  describe "source type" do
    before(:each) do
      @od = OD.create!
    end
    
    it "must be 'HealthCenter'" do
      alert = HealthCenterAlert.create! :recipient_id => @od.id
      alert.source_type.should == "HealthCenter"
    end
  end
end