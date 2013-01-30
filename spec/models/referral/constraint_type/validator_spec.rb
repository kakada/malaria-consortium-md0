require "spec_helper"

describe Referral::ConstraintType::Validator do
  it "should return between validator object " do
    between = Referral::ConstraintType::Validator.get_validator("Between", *[10, 20])
    between.should be_kind_of Referral::ConstraintType::Between
    between.from.should eq 10
    between.to.should eq 20
  end
  
  it "should return collection validator object" do
    collection = Referral::ConstraintType::Validator.get_validator("Collection", [10, 20, 50, 10])
    collection.should be_kind_of Referral::ConstraintType::Collection
    collection.collection.should eq [10, 20, 50, 10]
  end
  
  
  it "should return difference_from validator object" do
    diff = Referral::ConstraintType::Validator.get_validator("DifferenceFrom", 10)
    diff.should be_kind_of Referral::ConstraintType::DifferenceFrom
    diff.equal.should eq 10
  end
  
  it "should return difference_from validator object" do
    equal = Referral::ConstraintType::Validator.get_validator("EqualTo", 100)
    equal.should be_kind_of Referral::ConstraintType::EqualTo
    equal.equal.should eq 100
  end
  
  it "should return difference_from validator object" do
    length = Referral::ConstraintType::Validator.get_validator("Length", 1030)
    length.should be_kind_of Referral::ConstraintType::Length
    length.length.should eq 1030
  end
  
  it "should return difference_from validator object" do
    max = Referral::ConstraintType::Validator.get_validator("Max", 9999)
    max.should be_kind_of Referral::ConstraintType::Max
    max.max.should eq 9999
  end
  
  
  it "should return difference_from validator object" do
    min = Referral::ConstraintType::Validator.get_validator("Min", 0)
    min.should be_kind_of Referral::ConstraintType::Min
    min.min.should eq 0
  end
  
  it "should return difference_from validator object" do
    start_with = Referral::ConstraintType::Validator.get_validator("StartWith", "malaria")
    start_with.should be_kind_of Referral::ConstraintType::StartWith
    start_with.start.should eq "malaria"
  end
  
  
  
end