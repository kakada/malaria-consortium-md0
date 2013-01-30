require "spec_helper"

describe Referral::ConstraintType::Length do 
  it "should validate number 346590 again length 6 with no error" do
    lengthValidator = Referral::ConstraintType::Length.new 6
    lengthValidator.validate(346590, "number").should eq true
    lengthValidator.errors.size.should eq 0
  end
  
  it "should validate number 346590 again length 5 with error" do
    lengthValidator = Referral::ConstraintType::Length.new(5)
    lengthValidator.validate("346590", "salary").should eq false
    lengthValidator.errors[0].should eq "Salary: 346590 does not have length match to 5"
  end
  
end