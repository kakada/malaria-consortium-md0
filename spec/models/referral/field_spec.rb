require "spec_helper"

describe Referral::Field do
  before(:each ) do
    
  end
  
  describe "Create Field" do
      before(:each) do
        @valid = { :position => 1 , 
                   :meaning => "Address", 
                   :template => "Address{original_message}"
                }
      end
      
      it "should create field with valid attribute" do
          ref = Referral::Field.new @valid
          count = Referral::Field.count
          ref.save.should eq true
          Referral::Field.count.should eq count+1
          ref.name.should eq Referral::Field.columnize(@valid[:position])
      end
      
      it "should require name to be unique " do
        Referral::Field.create! :position => 1, :meaning => "Tel", :template => "xxx"
        ref = Referral::Field.new @valid
        ref.save.should eq false
        ref.errors.full_messages.should eq ["Name has already been taken"]
      end
      
      it "should require mearning" do
        ref = Referral::Field.new @valid.merge(:meaning => "")
        ref.save.should eq false
      end
      
      it "should require template" do
        ref = Referral::Field.new @valid.merge(:template => "")
        ref.save.should eq false
      end
  end
  
  describe "clean format" do
    it "should clean message format stripping all non existing field" do
       
       f1 = Referral::Field.create! :position =>1 , :meaning => "m1", :template => "t1"
       f2 = Referral::Field.create! :position =>2 , :meaning => "m2", :template => "t2"
       
       clinic = Referral::MessageFormat.create!  :format => "{Field1}.{Field3}"
       hc =  Referral::MessageFormat.create!  :format => "{Field1}.{Field2}.{Field3}"
       
       f1.destroy
       Referral::MessageFormat.first.format.should eq "{Field3}"
       Referral::MessageFormat.last.format.should eq "{Field2}.{Field3}"
       
       f2.destroy
       Referral::MessageFormat.first.format.should eq "{Field3}"
       Referral::MessageFormat.last.format.should eq "{Field3}"
      
    end
    
  end
  
  it "should return tags for specific tags with the fields exist" do
    Referral::Field.create! :position => 1 , :meaning => "Address", :template => "Address{original_message}"
    Referral::Field.create! :position => 2 , :meaning => "Tel", :template => "Address{original_message}"
    
    Referral::Field.tags(["od", "phone_number"]).should eq  ["od", "phone_number", "Field1", "Field2"]
  end
  
  
end