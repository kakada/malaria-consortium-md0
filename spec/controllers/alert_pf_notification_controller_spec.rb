require 'spec_helper'

describe AlertPfNotificationController do
  include Devise::TestHelpers

  before(:each) do
    Place.create!(:name => "Phnom penh", :code => "pcode1" )
    @attribute = {
      :user_name => "admin",
      :email => "admin@yahoo.com",
      :password => "123456",
      :intended_place_code =>"pcode1",
      :phone_number => "0975553553",
      :role => User::Roles[0]
    }
    @user = User.create! @attribute
    sign_in @user
  end

  it "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:alerts)
  end

end
