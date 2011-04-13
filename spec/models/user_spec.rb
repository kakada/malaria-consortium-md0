require 'spec_helper'
require 'test_helper'

describe User do
  before(:each) do
    @valid_attributes = {
      :user_name => "value for user_name",
      :password => "value for password",
      :phone_number => "value for phone_number"
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@valid_attributes)
  end

  it "should have no blank phone_number" do
    user = User.new(@valid_attributes.merge(:phone_number=>""))
    user.save
    User.count.should == 0
  end

  it "should return phone numbers of user from district, province , national" do

    province1 = Place.create! :name => "Pro1", :code => "Pro1", :place_type => Place::Province
    district1 = Place.create! :name => "Dist1", :code => "Dist1" ,:parent_id =>province1.id, :place_type => Place::OD
    
    hc1 = health_center "hc1", district1.id
    
    user_hc1 = user "123456", hc1

    user_ds1 = user "1234511", district1
    user_ds2 = user "1234512", district1
    user_ds3 = user nil, district1

    user_pro1 = user "123458", province1
    user_pro2 = user nil, province1

    user_nat1 = national_user "1234591"
    user_nat2 = national_user "1234592"

    recipients = user_hc1.alert_numbers

    recipients.should =~["1234511", "1234512","123458", "1234591", "1234592"]
  end
end
