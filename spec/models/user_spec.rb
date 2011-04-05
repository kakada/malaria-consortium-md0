require 'spec_helper'

describe User do
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
end
