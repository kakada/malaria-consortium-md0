require "spec_helper"

describe Referal::ConstraintType::Max do
  it "should validate number 30 again max 50 with no error" do
    maxValidator = Referal::ConstraintType::Max.new 50
    maxValidator.validate(30, "Age").should eq true
    maxValidator.errors.size.should eq 0
  end
  
  it "should validate number 20 again max 20 with no error" do
    maxValidator = Referal::ConstraintType::Max.new 20
    maxValidator.validate(20, "Age").should eq true
    maxValidator.errors.size.should eq 0
  end
  
  it "should validate number 60 again 40 with error" do
    maxValidator = Referal::ConstraintType::Max.new 40
    maxValidator.validate(60, "Age").should eq false
    maxValidator.errors.size.should eq 1
    maxValidator.errors[0].should eq "Age: 60 should be less than or equal to 40"
  end
  
end