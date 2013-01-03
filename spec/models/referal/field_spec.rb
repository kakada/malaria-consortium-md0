require "spec_helper"

describe Referal::Field do
  before(:each ) do
    Referal::Field.create! :position => 1 , :meaning => "Address", :template => "Address{original_message}"
    Referal::Field.create! :position => 2 , :meaning => "Tel", :template => "Address{original_message}"
  end
  
  it "should return tags of field" do
    p Referal::Field.tags
  end
end