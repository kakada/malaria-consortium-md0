require "spec_helper"

describe Referal::ConstraintType::Validator do
  it "should return between validator object " do
    between = Referal::ConstraintType::Validator.get_validator("Between", *[10, 20])
    between.should be_kind_of Referal::ConstraintType::Between
    between.from.should eq 10
    between.to.should eq 20
  end
  
  it "should return collection validator object" do
    collection = Referal::ConstraintType::Validator.get_validator("Collection", [10, 20, 50, 10])
    collection.should be_kind_of Referal::ConstraintType::Collection
    collection.collection.should eq [10, 20, 50, 10]
  end
  
  
  it "should return difference_from validator object" do
    diff = Referal::ConstraintType::Validator.get_validator("DifferenceFrom", 10)
    diff.should be_kind_of Referal::ConstraintType::DifferenceFrom
    diff.equal.should eq 10
  end
  
  it "should return difference_from validator object" do
    equal = Referal::ConstraintType::Validator.get_validator("EqualTo", 100)
    equal.should be_kind_of Referal::ConstraintType::EqualTo
    equal.equal.should eq 100
  end
  
  it "should return difference_from validator object" do
    length = Referal::ConstraintType::Validator.get_validator("Length", 1030)
    length.should be_kind_of Referal::ConstraintType::Length
    length.length.should eq 1030
  end
  
  it "should return difference_from validator object" do
    max = Referal::ConstraintType::Validator.get_validator("Max", 9999)
    max.should be_kind_of Referal::ConstraintType::Max
    max.max.should eq 9999
  end
  
  
  it "should return difference_from validator object" do
    min = Referal::ConstraintType::Validator.get_validator("Min", 0)
    min.should be_kind_of Referal::ConstraintType::Min
    min.min.should eq 0
  end
  
  it "should return difference_from validator object" do
    start_with = Referal::ConstraintType::Validator.get_validator("StartWith", "malaria")
    start_with.should be_kind_of Referal::ConstraintType::StartWith
    start_with.start.should eq "malaria"
  end
  
  
  
end