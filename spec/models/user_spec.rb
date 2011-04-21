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

    hc1 = health_center "hc1", district1.id

    user_hc1 = user :phone_number => "123456", :place => hc1

    user_ds1 = user :phone_number => "1234511", :place => district1
    user_ds2 = user :phone_number => "1234512", :place => district1
    user_ds3 = user :user_name => "foo", :password => '123456', :email => "foo@foo.com", :place => district1

    user_pro1 = user :phone_number => "123458", :place => province1
    user_pro2 = user :user_name => "foo2", :password => '123456', :email => "foo2@foo.com", :place => province1

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

    user_vill1 = user :phone_number => "1", :place => vill1

    user_hc1 = user :phone_number => "123456", :place => hc1

    user_ds1 = user :phone_number => "1234511", :place => district1
    user_ds2 = user :phone_number => "1234512", :place => district1
    user_ds3 = user :user_name => "foo", :password => '123456', :email => "foo@foo.com", :place => district1

    user_pro1 = user :phone_number => "123458", :place => province1
    user_pro2 = user :user_name => "foo2", :password => '123456', :email => "foo2@foo.com", :place => province1

    user_nat1 = national_user "1234591"
    user_nat2 = national_user "1234592"
    
    recipients = user_vill1.alert_numbers

    recipients.should =~ ["123456", "1234511", "1234512","123458", "1234591", "1234592"]
  end

  it "should not be able to report unless she's in a health center or village" do
    [user(:phone_number => "1"), user(:phone_number => "2", :place => od("2")), user(:phone_number => "3", :place => province("3"))].each do |u|
      u.can_report?().should be_false
    end
  end

  it "should be able to report if she's in a health center or village" do
    [user(:phone_number => "1", :place => village("1")), user(:phone_number => "2", :place => health_center("2"))].each do |u|
      u.can_report?().should be_true
    end
  end

  it "should provide the correct parser" do
    parser = user(:phone_number => "1", :place => health_center("1")).report_parser
    parser.class.should == HCReportParser

    parser = user(:phone_number => "2", :place => village("2")).report_parser
    parser.class.should == VMWReportParser
  end

  it "should create 2 users with valid attributes" do
    @attrib = {
        :user_name => ["foo","bar"],
        :email => ["foo@yahoo.com","bar@yahoo.com"],
        :password => ["123456", "234567"],
        :phone_number => ["0975553553", "0975425678"],
        :place_id => ["1","3"]
    }
    User.save_bulk(@attrib)
    User.count.should == 2  
  end
  
  it "should write temp place csv to disk" do
    user = user(:phone_number => "1")
    
    file_name = File.join(File.dirname(__FILE__),"test.csv")
    File.open(file_name,"r+b") do |file|
      user.write_places_csv file
    end
    
    file_name = Rails.root.join("public","placescsv", "#{user.id}.csv")
    File.exists?(file_name).should == true
    
    user.places_csv_file_name.should == file_name
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
      valid_user = User.new :user_name => "foo", :password => "foo", :email => "a@a.com"
      valid_user.valid?.should be_true
    end
    
    it "should be invalid if it has no phone and no username" do
      valid_user = User.new :user_name => "", :password => "foo", :email => "a@a.com"
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
end
