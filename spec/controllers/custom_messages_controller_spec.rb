require 'spec_helper'

describe CustomMessagesController do
  include Helpers
  include Devise::TestHelpers

  before(:each) do
    sign_in User.make
  end

  it { should be_instance_of CustomMessagesController }

  describe "new custom message" do
    it "should render new template" do
      get :new
      response.should render_template :new
    end
  end

  describe "send sms to selected type" do
    describe "message with valid attributes" do
      before(:each) do
        @valid_attribute = {
          :sms => "this is a a valid sms",
          :place_id => "1",
          :places => ["OD","HealthCenter"],
          :users => ["1","2","3"],
          :format =>"js"
        }
        @format = "js"
        @custom_message = Object.new
        CustomMessage.stub!(:new).with(@valid_attribute[:sms]).and_return(@custom_message)
        @custom_message.stub!(:valid?).and_return(true)

        CustomMessage.stub!(:get_users).with(@valid_attribute[:place_id].to_i,@valid_attribute[:places]).and_return([])
        @custom_message.stub!(:send_sms_users)
        User.stub!(:find).with(@valid_attribute[:users]).and_return([])

      end

      it "should create a valid custom_message object" do
        CustomMessage.should_receive(:new).and_return(@custom_message)
        post :create, @valid_attribute
      end

      it "should be validate the custome_message return true" do
        @custom_message.should_receive(:valid?).and_return(true)
        post :create, @valid_attribute
      end

      it "should find the users from place_id top hierachy in the places type collection" do
        CustomMessage.should_receive(:get_users).with(@valid_attribute[:place_id].to_i,@valid_attribute[:places])
        post :create , @valid_attribute
      end

      it "should find the user for the users collection" do
        User.should_receive(:find).with(@valid_attribute[:users])
        post :create, @valid_attribute
      end

      it "should render create.js.erb template" do
        post :create,  @valid_attribute
        response.should render_template :create
      end
    end
  end
end
