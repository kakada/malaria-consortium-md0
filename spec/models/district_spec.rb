require 'spec_helper'

describe District do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :name_kh => "value for name_kh",
      :code => "value for code"
    }
  end

  it "should create a new instance given valid attributes" do
    District.create!(@valid_attributes)
  end
end
