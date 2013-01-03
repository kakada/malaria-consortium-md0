require "spec_helper"

describe Referal::ConstraintType::Collection do
  
  it "should validate string 'aaa' in collection ['aaa', 'bbb', 'ddd' ] without error" do
    collectionValidator = Referal::ConstraintType::Collection.new ['aaa', 'bbb', 'ddd' ]
    collectionValidator.validate('aaa', "item").should eq true
    collectionValidator.errors.size.should eq 0
  end
  
  it "should validate string 'aaa' in collection ['ccc', 'bbb', 'ddd' ] with error" do
    collectionValidator = Referal::ConstraintType::Collection.new ['ccc', 'bbb', 'ddd' ]
    collectionValidator.validate( 'aaa', "item").should eq false
    collectionValidator.errors.size.should eq 1
    collectionValidator.errors[0].should eq "Item: aaa should be between [ccc, bbb, ddd]" 
  end
  
  
end
