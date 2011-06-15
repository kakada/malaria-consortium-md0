require 'spec_helper'
require 'test_helper'

describe User do
  include Helpers

  before(:each) do
    @valid_attributes = {
      :user_name => "value for user_name",
      :password => "value for password",
      :phone_number => "123456"
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

    hc1 = district1.health_centers.make

    user_hc1 = user :phone_number => "123456", :place => hc1

    user :phone_number => "1234511", :place => district1
    user :phone_number => "1234512", :place => district1
    user :user_name => "foo", :password => '123456', :email => "foo@foo.com", :place => district1

    user :phone_number => "123458", :place => province1
    user :user_name => "foo2", :password => '123456', :email => "foo2@foo.com", :place => province1

    national_user "1234591"
    national_user "1234592"

    recipients = user_hc1.alert_numbers

    recipients.should =~["1234511", "1234512","123458", "1234591", "1234592"]
  end

  it "should return phone numbers of user from health center, district, province, national when user is a village malaria worker" do
    province1 = Province.create! :name => "Pro1", :code => "Pro1"
    district1 = province1.ods.create! :name => "Dist1", :code => "Dist1"
    hc1 = district1.health_centers.make
    vill1 = hc1.villages.make

    user_vill1 = user :phone_number => "1", :place => vill1

    user_hc1 = user :phone_number => "123456", :place => hc1

    user :phone_number => "1234511", :place => district1
    user :phone_number => "1234512", :place => district1
    user :user_name => "foo", :password => '123456', :email => "foo@foo.com", :place => district1

    user :phone_number => "123458", :place => province1
    user :user_name => "foo2", :password => '123456', :email => "foo2@foo.com", :place => province1

    national_user "1234591"
    national_user "1234592"

    recipients = user_vill1.alert_numbers

    recipients.should =~ ["123456", "1234511", "1234512","123458", "1234591", "1234592"]
  end

  it "should not be able to report unless she's in a health center or village" do
    [user(:phone_number => "1"), user(:phone_number => "2", :place => OD.make(:code => '2')), user(:phone_number => "3", :place => Province.make(:code => '3'))].each do |u|
      u.can_report?().should be_false
    end
  end

  it "should be able to report if she's in a health center or village" do
    [user(:phone_number => "1", :place => Village.make(:code => '1')), user(:phone_number => "2", :place => HealthCenter.make(:code => 2))].each do |u|
      u.can_report?().should be_true
    end
  end

  it "should provide the correct parser" do
    parser = user(:phone_number => "1", :place => HealthCenter.make(:code => '1')).report_parser
    parser.class.should == HCReportParser

    parser = user(:phone_number => "2", :place => Village.make(:code => '2')).report_parser
    parser.class.should == VMWReportParser
  end

  it "should create 2 users with valid attributes" do
    Province.create! :name => "Pro1", :code => "Pro1"
    Province.create! :name => "Pro1", :code => "Pro2"

    @attrib = {
        :user_name => ["foo","bar"],
        :email => ["foo@yahoo.com","bar@yahoo.com"],
        :password => ["123456", "234567"],
        :phone_number => ["0975553553", "0975425678"],
        :place_code => ["Pro1","Pro2"],
        :role => [User::Roles[0], User::Roles[1] ]
    }
    User.save_bulk(@attrib)
    User.count.should == 2
  end

  describe "intended place code" do
    it "should try to find place by code before saving if intended place code is not nil" do
      province1 = Province.create! :name => "Pro1", :code => "Pro1"
      user = User.new :user_name => 'foo', :email => 'fooaddress@foo.com', :password => '123456', :intended_place_code => "Pro1"
      user.save
      user.valid?.should be_true
      user.place.should == province1
    end

    it "should cause validation to fail if it doesn't belong to a place" do
      user = User.new :user_name => 'foo', :email => 'fooaddress@foo.com', :password => '123456', :intended_place_code => "Pro1"
      user.save
      user.valid?.should be_false
      user.errors[:intended_place_code].count.should == 1
    end

    it "should not change a user's place upon update if it's nil or empty" do
      province1 = Province.create! :name => "Pro1", :code => "Pro1"
      user = User.create! :user_name => 'foo', :email => 'fooaddress@foo.com', :password => '123456', :place_id => province1.id

      user.intended_place_code = ''
      user.save
      user.place_id.should == province1.id

      user.intended_place_code = nil
      user.save
      user.place_id.should == province1.id
    end
  end

  describe "email validations" do
    it "should not create users with invalid email address" do
      invalid_user = User.new :user_name => 'foo', :email => 'fooaddress', :password => '123456'
      invalid_user.valid?.should be_false
      invalid_user.errors.size.should == 1
      invalid_user.errors[:email].should_not == nil
    end

    it "should create users with valid email address" do
      valid_user = User.new :user_name => 'foo', :email => 'fooaddress@foo.com', :password => '123456'
      valid_user.valid?.should be_true
      valid_user.errors.size.should == 0
    end

    it "should be unique" do
      valid_user = User.create! :user_name => 'foo', :password => '123456', :phone_number => '123567', :email => "foo@foo.com"
      invalid_user = User.new :user_name => 'foo2', :password => '123456', :phone_number => '123568', :email => "foo@foo.com"
      invalid_user.valid?.should be_false
    end
  end

  describe "username validations" do
    it "should be unique" do
      valid_user = User.create! :user_name => 'foo', :password => '123456', :phone_number => '123567'
      invalid_user = User.new :user_name => 'foo', :password => '123456', :phone_number => '123568'
      invalid_user.valid?.should be_false
    end
  end

  describe "phone number validations" do
    it "should not create users with invalid phone number" do
      invalid_user = User.new :user_name => 'foo', :password => '123456', :phone_number => '1239123-1392132'
      invalid_user.valid?.should be_false
      invalid_user.errors.size.should == 1
      invalid_user.errors[:phone_number].should_not == nil
    end

    it "should create users with valid phone number" do
      valid_user = User.new :user_name => 'foo', :password => '123456', :phone_number => '123567'
      valid_user.valid?.should be_true
    end

    it "should be unique" do
      valid_user = User.create! :user_name => 'foo', :password => '123456', :phone_number => '123567'
      invalid_user = User.new :user_name => 'foo2', :password => '123456', :phone_number => '123567'
      invalid_user.valid?.should be_false
    end
  end

  describe "role validations" do
    it "should be in the list of roles" do
      valid_user = User.create! :user_name => 'foo', :password => '123456', :phone_number => '123567', :role => 'admin'
      valid_user2 = User.create! :user_name => 'foo2', :password => '1234562', :phone_number => '1235672', :role => 'national'

      invalid_user = User.new :user_name => 'foo23', :password => '12345623', :phone_number => '12356723', :role => 'foo'
      invalid_user.valid?.should be_false
    end
  end

  describe "either has a phone number or a username AND a password AND an email" do
    it "should be valid if it only has a phone number" do
      valid_user = User.new :phone_number => '123456'
      valid_user.valid?.should be_true
    end

    it "should be valid if it has username, password and email" do
      valid_user = User.new :user_name => "foo", :password => "123456", :email => "a@a.com"
      valid_user.valid?.should be_true
    end

    it "should be invalid if it has no phone and no username" do
      valid_user = User.new :user_name => "", :password => "123456", :email => "a@a.com"
      valid_user.valid?.should be_false
    end

    it "should be invalid if it has no phone and no password" do
      valid_user = User.new :user_name => "foo", :password => "", :email => "a@a.com"
      valid_user.valid?.should be_false
    end

    it "should be invalid if it has no phone and no email" do
      valid_user = User.new :user_name => "foo", :password => "foo", :email => ""
      valid_user.valid?.should be_false
    end
  end

  describe "setting nuntium custom attributes" do

    before(:each) do
      @nuntium_api.should_not_receive(:set_custom_attributes).with('sms://', anything)
    end

    it "should set custom attributes for new user in village" do
      @nuntium_api.should_receive(:set_custom_attributes).with('sms://123', {:application => 'md0'})
      User.create! :phone_number => '123', :place => Village.make
    end

    it "should not set custom attributes for user in province" do
      @nuntium_api.should_not_receive(:set_custom_attributes)
      User.create! :phone_number => '123', :place => province('foo')
    end

    it "should not set custom attributes if it has no phone" do
      @nuntium_api.should_not_receive(:set_custom_attributes)
      User.create! :user_name => 'user', :password => '123456', :email => 'user@email.com'
    end

    it "should unset custom attributes if moved to province" do
      u = User.create! :phone_number => '123', :place => Village.make
      @nuntium_api.should_receive(:set_custom_attributes).with('sms://123', {:application => nil})
      u.place = province('bar')
      u.save!
    end

    it "should clear the custom attribute when the phone is unset" do
      u = User.create! :user_name => 'user', :password => '123456', :email => 'user@email.com', :phone_number => '123', :place => Village.make
      @nuntium_api.should_receive(:set_custom_attributes).with('sms://123', {:application => nil})
      u.phone_number = nil
      u.save!
    end

    it "should clear custom attributes but not set new ones when moving to province with new number" do
      u = User.create! :phone_number => '123', :place => Village.make
      @nuntium_api.should_receive(:set_custom_attributes).with('sms://123', {:application => nil})
      @nuntium_api.should_not_receive(:set_custom_attributes).with('sms://456', anything)
      u.phone_number = '456'
      u.place = province('bar')
      u.save!
    end

    it "should not set or clear custom attributes for new or updated province user" do
      @nuntium_api.should_not_receive(:set_custom_attributes)
      u = User.create! :phone_number => '123', :place => province('foo')
      u.phone_number = '456'
      u.save!
    end
  end

  describe "last report" do
    it "assigns valid" do
      village = Village.make
      user = User.create! :phone_number => '123', :place => village
      report = VMWReport.create! :malaria_type => 'F', :sex => 'Male', :age => 23, :place => village, :village => village, :sender => user
      user.last_report_id.should eq(report.id)
      user.last_report_error.should be_false
    end

    it "assigns error" do
      village = Village.make
      user = User.create! :phone_number => '123', :place => village
      report = VMWReport.create! :error => true, :place => village, :village => village, :sender => user
      user.last_report_id.should eq(report.id)
      user.last_report_error.should be_true
    end
  end

end
