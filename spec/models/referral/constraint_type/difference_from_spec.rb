require "spec_helper"

describe Referral::ConstraintType::DifferenceFrom do
  it "should validate number 40 again max 30 with no error" do
    diffValidator = Referral::ConstraintType::DifferenceFrom.new 30
    diffValidator.validate(40, "Age").should eq true
    diffValidator.errors.size.should eq 0
  end
  
  it "should validate number 60 equal to 60 with error" do
    diffValidator = Referral::ConstraintType::DifferenceFrom.new 60
    diffValidator.validate(60, "Age").should eq false
    diffValidator.errors.size.should eq 1
    diffValidator.errors[0].should eq "Age: 60 should be not be equal to 60"
  end
  
end