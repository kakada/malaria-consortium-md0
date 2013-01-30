require "spec_helper"

describe Referral::ConstraintType::Min do
  it "should validate number 30 again min 20 with no error" do
    minValidator = Referral::ConstraintType::Min.new 20
    minValidator.validate(30, "Age").should eq true
    minValidator.errors.size.should eq 0
  end
  
  it "should validate number 20 again min 20 with no error" do
    minValidator = Referral::ConstraintType::Min.new 20
    minValidator.validate(20, "Age").should eq true
    minValidator.errors.size.should eq 0
  end
  
  it "should validate number 30 again 40 with error" do
    minValidator = Referral::ConstraintType::Min.new 40
    minValidator.validate(30, "Age").should eq false
    minValidator.errors.size.should eq 1
    minValidator.errors[0].should eq "Age: 30 should be greater than or equal to 40"
  end
  
end