require 'spec_helper'

describe Referal::HCParser do
  before(:each) do
    od = OD.make :abbr => "KPS"
    @user = User.make :user_name => "bopha",  :phone_number => "85597888123", :place => od
    @params = { :text => "0971234567KPS001001123456", :sender => @user }
    @hc = HealthCenter.make :code => "123456"
    
    max    =  Referal::ConstraintType::Validator.get_validator("Max", 90 )
    min    =  Referal::ConstraintType::Validator.get_validator("Min", 10 )
    
    collection = Referal::ConstraintType::Validator.get_validator("Collection", "Female,Male" )
    
    
    # create 2 dynamic fields called Field1, Field2 dynamically
    @fieldAge = Referal::Field.create! :position => 1, :meaning => "Age", :template => "Age" #Field1
    @fieldSex = Referal::Field.create! :position => 2, :meaning => "Sex", :template => "Sex" #Field2
    
    # create max constraint for Field1(age)
    constraintAge = @fieldAge.constraints.build
    constraintAge.validator = max
    constraintAge.save
    
    # create min constraint for Field1(age)
    constraintAge = @fieldAge.constraints.build
    constraintAge.validator = min
    constraintAge.save
    
    # create collection constraint for Field1(sex)
    constraintCollection = @fieldSex.constraints.build
    constraintCollection.validator = collection
    constraintCollection.save
    
  end
  
  describe "parse" do
     it "should parse message successfully" do
       message_format = Referal::MessageFormat.create! :format => "{phone_number}.{slip_code}.{Field1}.{Field2}", :sector => Referal::MessageFormat::TYPE_HC
      
       Referal::ClinicReport.create!(:slip_code => "KPS001100")
      
       parser = Referal::HCParser.new({:text=>"09712345678.KPS001100.25.Male", :sender => @user})
       parser.message_format = message_format 
       parser.parse
       parser.report.should be_kind_of Referal::HCReport
      
     end
  end
  
  describe "scan_slip_code" do
    it "should raise referal_slip_code_not_exist" do
      message_format = Referal::MessageFormat.create! :format => "{phone_number}.{slip_code}.{Field1}", 
                                                      :sector => Referal::MessageFormat::TYPE_HC
      parser = Referal::HCParser.new({:text=>"09712345678.KPS001100", :sender => @user})
      expect{parser.scan_slip_code("KPS001100")}.to raise_error(Exception, "referal_slip_code_not_exist" ) 
    end
    
    it "should not raise any exception for slip_code that was sent by clinic" do
      
      message_format = Referal::MessageFormat.create! :format => "{phone_number}.{slip_code}.{Field1}", 
                                                      :sector => Referal::MessageFormat::TYPE_HC
                                                    
      Referal::ClinicReport.create! :slip_code => "KPS001100"                                              
      parser = Referal::HCParser.new({:text=>"09712345678.KPS001100", :sender => @user})
      parser.scan_slip_code("KPS001100")
      parser.options[:slip_code].should eq "KPS001100"
    end
    
  end
  
end
