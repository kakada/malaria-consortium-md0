require "spec_helper"

describe Referal::Field do
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
          ref = Referal::Field.new @valid
          count = Referal::Field.count
          ref.save.should eq true
          Referal::Field.count.should eq count+1
          ref.name.should eq Referal::Field.columnize(@valid[:position])
      end
      
      it "should require name to be unique " do
        Referal::Field.create! :position => 1, :meaning => "Tel", :template => "xxx"
        ref = Referal::Field.new @valid
        ref.save.should eq false
        ref.errors.full_messages.should eq ["Name has already been taken"]
      end
      
      it "should require mearning" do
        ref = Referal::Field.new @valid.merge(:meaning => "")
        ref.save.should eq false
      end
      
      it "should require template" do
        ref = Referal::Field.new @valid.merge(:template => "")
        ref.save.should eq false
      end
  end
  
  describe "clean format" do
    it "should clean message format stripping all non existing field" do
       
       f1 = Referal::Field.create! :position =>1 , :meaning => "m1", :template => "t1"
       f2 = Referal::Field.create! :position =>2 , :meaning => "m2", :template => "t2"
       
       clinic = Referal::MessageFormat.create!  :format => "{Field1}.{Field3}"
       hc =  Referal::MessageFormat.create!  :format => "{Field1}.{Field2}.{Field3}"
       
       f1.destroy
       Referal::MessageFormat.first.format.should eq "{Field3}"
       Referal::MessageFormat.last.format.should eq "{Field2}.{Field3}"
       
       f2.destroy
       Referal::MessageFormat.first.format.should eq "{Field3}"
       Referal::MessageFormat.last.format.should eq "{Field3}"
      
    end
    
  end
  
  it "should return tags for specific tags with the fields exist" do
    Referal::Field.create! :position => 1 , :meaning => "Address", :template => "Address{original_message}"
    Referal::Field.create! :position => 2 , :meaning => "Tel", :template => "Address{original_message}"
    
    Referal::Field.tags(["od", "phone_number"]).should eq  ["od", "phone_number", "Field1", "Field2"]
  end
  
  
end