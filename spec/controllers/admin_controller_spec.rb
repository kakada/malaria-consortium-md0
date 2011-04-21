require 'spec_helper'
require 'test_helper'

describe AdminController do
  include Helpers
  before(:each) do
    @user = admin_user "12345678"
    test_sign_in(@user) #sign the user in
    controller.signed_in?.should be_true #make sure it was signed
  end

  #Delete this example and add some real ones
  it "should use AdminController" do
    controller.should be_an_instance_of(AdminController)
  end

  describe "newusers" do
    it "should be success at /admin/newusers" do
      get :newusers
      response.should be_success
    end
  end
  
  describe "createusers" do
      describe "successfully created" do
        before(:each) do
          @attrib = {
              :user_name => ["foo","bar"],
              :email => ["foo@yahoo.com","bar@yahoo.com"],
              :password => ["123456", "234567"],
              :phone_number => ["097 5553553", "0975425678"],
              :place_id => ["1","3"]
          }
        end
        it "should redirect to users pages " do
          post :createusers ,:admin => @attrib
          response.should redirect_to :action => :users
        end
      end
  end

  describe "Show user list admin/users" do
    it "should render the users template" do
      get :users
      response.should render_template "users"
    end
  end
end
