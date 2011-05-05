require 'spec_helper'

describe CustomMessagesController do
  include Helpers
  
  before(:each) do
    @user = admin_user "12345678"
    test_sign_in(@user) #sign the user in
    controller.signed_in?.should be_true #make sure it was signed
  end

  it "should use CustomMessageController" do
    controller.should be_instance_of CustomMessagesController
  end

  describe "new custom_message" do
    it "should render new at new_custom_message_path" do
      get :new
      response.should render_template :new
    end
  end

  describe "send sms to selected type" do
    describe "message with valid attributes" do
      before(:each) do
        p1 = Place.create!(:name => "Phnom penh", :code => "pcode1", :type=>Place::Types[0])
        p2 = Place.create!(:name => "Kandal", :code => "pcode2", :type=>Place::Types[0])
        @places = [p1,p2]
        attrib_user1 = {
           :user_name => "bar",
           :email => "bar@yahoo.com",
           :password => "123456",
           :intended_place_code =>"pcode1",
           :phone_number => "0975553552",
           :role => User::Roles[0]
        }

        attrib_user2 = {
           :user_name => "foo",
           :email => "foo@yahoo.com",
           :password => "123456",
           :intended_place_code =>"pcode2",
           :phone_number => "0975553553",
           :role => User::Roles[0]
        }
        @user1 = User.create! attrib_user1
        @user2 = User.create! attrib_user2

        @attrib_sms = {
          :type => Place::Types[0],
          :sms => "message to be send less than 140 chars"
        }

        @custom_message = CustomMessage.new @attrib_sms
        CustomMessage.stub!(:new).with(@attrib_sms).and_return(@custom_message)

        @custom_message.stub!(:valid?).and_return(true)
        @custom_message.stub!(:send_to).with(@user1)
        @custom_message.stub!(:send_to).with(@user2)

        Place.stub!(:places_by_type).with(@attrib_sms[:type]).and_return(@places)
      end


      it "should find places and return 2 places" do
        Place.should_receive(:places_by_type).with(@attrib_sms[:type]).and_return(@places)
        post :create , @attrib_sms
      end

      it "should send message to user1 " do
        @custom_message.should_receive(:send_to).with(@user1)
        post :create, @attrib_sms
      end

      it "should send message to user2" do
        @custom_message.should_receive(:send_to).with(@user2)
        post :create, @attrib_sms
      end

      it "should render review template" do
        post :create, @attrib_sms
        response.should render_template :review
      end
    end

    describe "message with invalid attribute" do
      before(:each) do
        @attrib_sms = {
          :type => "Jut a  place type here",
          :sms => ""
        }
        @custom_message = CustomMessage.new @attrib_sms
        CustomMessage.stub!(:new).with(@attrib_sms).and_return(@custom_message)
        @custom_message.stub!(:valid?).and_return(false)
      end

      it "should render new template in custom message" do
        post :create, @attrib_sms
        response.should render_template :new
      end

    end

    

  end

  
end
