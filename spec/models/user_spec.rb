require 'spec_helper'
require 'test_helper'

describe User do
  include Helpers

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

  it "should return phone numbers of user from district, province, national when user is from health center" do
    province1 = Province.create! :name => "Pro1", :code => "Pro1"
    district1 = province1.ods.create! :name => "Dist1", :code => "Dist1"

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
  
  it "should return phone numbers of user from health center, district, province, national when user is a village malaria worker" do
    province1 = Province.create! :name => "Pro1", :code => "Pro1"
    district1 = province1.ods.create! :name => "Dist1", :code => "Dist1"
    hc1 = health_center "hc1", district1.id
    vill1 = village "vill1", "vill1", hc1.id

    user_vill1 = user "1", vill1

    user_hc1 = user "123456", hc1

    user_ds1 = user "1234511", district1
    user_ds2 = user "1234512", district1
    user_ds3 = user nil, district1

    user_pro1 = user "123458", province1
    user_pro2 = user nil, province1

    user_nat1 = national_user "1234591"
    user_nat2 = national_user "1234592"
    
    recipients = user_vill1.alert_numbers

    recipients.should =~ ["123456", "1234511", "1234512","123458", "1234591", "1234592"]
  end

  it "should not be able to report unless she's in a health center or village" do
    [user("1"), user("2", od("2")), user("3", province("3"))].each do |u|
      u.can_report?().should be_false
    end
  end

  it "should be able to report if she's in a health center or village" do
    [user("1", village("1")), user("2", health_center("2"))].each do |u|
      u.can_report?().should be_true
    end
  end

  it "should provide the correct parser" do
    parser = user("1", health_center("1")).report_parser
    parser.class.should == HCReportParser

    parser = user("2", village("2")).report_parser
    parser.class.should == VMWReportParser
  end

  it "should create 2 users with valid attributes" do
    @attrib = {
        :user_name => ["foo","bar"],
        :email => ["foo@yahoo.com","bar@yahoo.com"],
        :password => ["123456", "234567"],
        :phone_number => ["097 5553553", "0975425678"],
        :place_id => ["1","3"]
    }
    User.save_bucks(@attrib)
    User.count.should == 2  
  end

end
