require 'spec_helper'
require 'test_helper'

describe AlertsController do
  include Helpers
  
  before(:each) do
    @user = admin_user "12345678"
    test_sign_in(@user) #sign the user in
    controller.signed_in?.should be_true #make sure it was signed
  end
  
  describe "health center" do
    it "should render health center template" do
      #get :health_center
      #response.should render_template "health_center"
    end
  end
end