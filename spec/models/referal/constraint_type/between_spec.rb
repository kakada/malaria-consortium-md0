require "spec_helper"

describe Referal::ConstraintType::Between do
  
  it "should validate number 30 between 20, 31 with no error" do
    betweenValidator = Referal::ConstraintType::Between.new(20, 31)
    betweenValidator.validate(30, "Age").should eq true
    betweenValidator.errors.size.should eq 0
  end
  
  it "should validate number 30 between 20, 30 with no error" do
    betweenValidator = Referal::ConstraintType::Between.new(20, 31)
    betweenValidator.validate(30, "Age").should eq true
    betweenValidator.errors.size.should eq 0
  end
  
  it "should validate number 30 between 20 , 28 with error" do
    betweenValidator = Referal::ConstraintType::Between.new(20, 28)
    betweenValidator.validate(30, "Age").should eq false
    betweenValidator.errors[0].should eq "Age: 30 should be between 20, 28"
  end
  
  it "should validate number 15 between 20 , 28 with error" do
    betweenValidator = Referal::ConstraintType::Between.new(20, 28)
    betweenValidator.validate(15, "Age").should eq false
    betweenValidator.errors[0].should eq "Age: 15 should be between 20, 28"
  end
  
end