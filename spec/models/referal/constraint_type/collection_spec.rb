require "spec_helper"

describe Referal::ConstraintType::Collection do
  
  it "should validate string 'aaa' in collection (aaa,bbb, ddd) without error" do
    collectionValidator = Referal::ConstraintType::Collection.new "aaa,bbb, ddd" 
    collectionValidator.validate('aaa', "item").should eq true
    collectionValidator.errors.size.should eq 0
  end
  
  it "should validate string again (aaa,bbb, ddd) with case insensitivity" do
    collectionValidator = Referal::ConstraintType::Collection.new "aaa,bbb,ddd" 
    ["Aaa", "bBb", "DDD"].each do |str|
      collectionValidator.validate(str, "item").should eq true
      collectionValidator.errors.size.should eq 0
    end
  end
  
  it "should validate string  ddd in (aaa,bbb,ddd ) with error considering space " do
    collectionValidator = Referal::ConstraintType::Collection.new "aaa,bbb,ddd " 
    collectionValidator.validate('ddd', "item").should eq false
    collectionValidator.errors[0].should eq "Item: ddd should be in collection (aaa,bbb,ddd )" 
  end
  
  it "should validate string  dddd in (aaa,bbb,ddd ) with error because it does not match ^ddd& " do
    collectionValidator = Referal::ConstraintType::Collection.new "aaa,bbb,ddd " 
    collectionValidator.validate('dddd', "item").should eq false
    collectionValidator.errors[0].should eq "Item: dddd should be in collection (aaa,bbb,ddd )" 
  end
  
  it "should validate string 'aaa' in collection (ccc, bbb, ddd) with error" do
    collectionValidator = Referal::ConstraintType::Collection.new "ccc, bbb, ddd"
    collectionValidator.validate( 'aaa', "item").should eq false
    collectionValidator.errors.size.should eq 1
    collectionValidator.errors[0].should eq "Item: aaa should be in collection (ccc, bbb, ddd)" 
  end
  
  
end
