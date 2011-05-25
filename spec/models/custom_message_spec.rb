require 'spec_helper'
require 'test_helper'

describe CustomMessage do
  include Helpers

  before(:each) do
      @valid_attributes = {
        :sms => "this is a message with length less than 140 ",
        :type => Place::Types[0]
      }
      @custom_message = CustomMessage.new @valid_attributes
  end
  
  describe "with valid attribute" do
    it "should create an object type of CustomMessage" do
      @custom_message.should be_instance_of CustomMessage
    end

    it "should have valid sms and type " do
      @custom_message.sms.should == @valid_attributes[:sms]
      @custom_message.type.should == @valid_attributes[:type]
    end

    it "should be valid " do
      @custom_message.valid?.should == true
    end

    it "should have no errors when validating" do
      @custom_message.valid?
      @custom_message.errors.size.should == 0
    end
  end

  describe "with invalid attribute" do
    before(:each) do
      @invalid_attributes = {
        :sms => "   ",
        :type => "invalid type"
      }
      @custom_message = CustomMessage.new @invalid_attributes
    end

    it "should create an object type of CustomMessage" do
      @custom_message.should be_instance_of CustomMessage
    end

    it "should have valid sms and type " do
      @custom_message.sms.should == @invalid_attributes[:sms]
      @custom_message.type.should == @invalid_attributes[:type]
    end

    it "should be invalid " do
      @custom_message.valid?.should == false
    end

    it "should have 2 errors when validating" do
      @custom_message.valid?
      @custom_message.errors.size.should == 2
      @custom_message.errors[:sms].should_not be_nil
      @custom_message.errors[:type].should_not be_nil
    end
  end

  describe "send sms to user" do
    before(:each) do
      Place.create!(:name => "Phnom penh", :code => "pcode1")
      @attribute = {
         :user_name => "admin",
         :email => "admin@yahoo.com",
         :password => "123456",
         :intended_place_code =>"pcode1",
         :phone_number => "0975553553",
         :role => User::Roles[0]
      }
      
      @user = User.create! @attribute

      @message = {
                :from => "sms://md0",
                :subject => "",
                :body => @custom_message.sms,
                :to => @user.phone_number.with_sms_protocol
      }

      @nuntium = Object.new
      Nuntium.stub!(:new_from_config).and_return(@nuntium)
      @nuntium.stub!(:send_ao).with(@message)
    end

    it "should make nuntium send_ao with message" do
      @nuntium.should_receive(:send_ao).with(@message)
      @custom_message.send_to(@user)
    end

  end
end
