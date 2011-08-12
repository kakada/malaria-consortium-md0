require 'spec_helper'

describe CustomMessagesController do
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
          :place_id => nil ,
          :places => ["OD","HealthCenter"],
          :users => ["1","2","3"],
          :format =>"js"
        }
        @custom_message = Object.new
        CustomMessage.stub!(:new).with(@valid_attribute[:sms]).and_return(@custom_message)
        @custom_message.stub!(:valid?).and_return(true)

        @custom_message.stub!(:send_sms_users)
        User.stub!(:find).with(@valid_attribute[:users]).and_return([])
        User.stub!(:user_from_place).and_return([])

      end

      it "should create a valid custom_message object" do
        CustomMessage.should_receive(:new).and_return(@custom_message)
        post :create, @valid_attribute
      end

      it "should be validate the custome_message return true" do
        @custom_message.should_receive(:valid?).and_return(true)
        post :create, @valid_attribute
      end

      it "should render create.js.erb template" do
        post :create,  @valid_attribute
        response.should render_template :create
      end
    end
  end
end
