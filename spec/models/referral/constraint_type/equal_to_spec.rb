require "spec_helper"

describe Referral::ConstraintType::EqualTo do
  it "should validate number 30 again max 30 with no error" do
    equalValidator = Referral::ConstraintType::EqualTo.new 30
    equalValidator.validate(30, "Age").should eq true
    equalValidator.errors.size.should eq 0
  end
  
  it "should validate number 60 equal to 40 with error" do
    equalValidator = Referral::ConstraintType::EqualTo.new 40
    equalValidator.validate(60, "Age").should eq false
    equalValidator.errors.size.should eq 1
    equalValidator.errors[0].should eq "Age: 60 should be equal to 40"
  end
  
end