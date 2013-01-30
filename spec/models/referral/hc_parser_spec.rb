require 'spec_helper'

describe Referral::HCParser do
  before(:each) do
    od = OD.make :abbr => "KPS"
    @user = User.make :user_name => "bopha",  :phone_number => "85597888123", :place => od
    @params = { :text => "0971234567KPS001001123456", :sender => @user }
    @hc = HealthCenter.make :code => "123456"
    
    max    =  Referral::ConstraintType::Validator.get_validator("Max", 90 )
    min    =  Referral::ConstraintType::Validator.get_validator("Min", 10 )
    
    collection = Referral::ConstraintType::Validator.get_validator("Collection", "Female,Male" )
    
    
    # create 2 dynamic fields called Field1, Field2 dynamically
    @fieldAge = Referral::Field.create! :position => 1, :meaning => "Age", :template => "Age" #Field1
    @fieldSex = Referral::Field.create! :position => 2, :meaning => "Sex", :template => "Sex" #Field2
    
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
  
  describe "analyse od name" do
    it "should raise exception if od is nil" do
        parser = Referral::HCParser.new({})
        expect{parser.analyse_od_name(nil)}.to raise_error(Exception, "referral_invalid_od" )
    end
     
    it "should exception if od abbr does not exist" do
        parser = Referral::HCParser.new({})
        expect{parser.analyse_od_name("xxxod")}.to raise_error(Exception, "referral_invalid_od" )
    end
    
    it "should store od_name if od abbr existed" do
      od = OD.make :abbr => "SAMP"
      parser = Referral::HCParser.new({})
      parser.analyse_od_name("SAMP")
      parser.options[:od_name].should eq "SAMP"
    end
    
  end
  
  describe "parse" do
     it "should parse message successfully" do
       message_format = Referral::MessageFormat.create! :format => "{phone_number}.{slip_code}.{Field1}.{Field2}", :sector => Referral::MessageFormat::TYPE_HC
      
       Referral::ClinicReport.create!(:slip_code => "KPS001100")
      
       parser = Referral::HCParser.new({:text=>"09712345678.KPS001100.25.Male", :sender => @user})
       parser.message_format = message_format 
       parser.parse
       parser.report.should be_kind_of Referral::HCReport
      
     end
  end
  
  describe "scan_slip_code" do
    it "should raise referral_slip_code_not_exist" do
      message_format = Referral::MessageFormat.create! :format => "{phone_number}.{slip_code}.{Field1}", 
                                                      :sector => Referral::MessageFormat::TYPE_HC
      parser = Referral::HCParser.new({:text=>"09712345678.KPS001100", :sender => @user})
      expect{parser.scan_slip_code("KPS001100")}.to raise_error(Exception, "referral_slip_code_not_exist" ) 
    end
    
    it "should not raise any exception for slip_code that was sent by clinic" do
      
      message_format = Referral::MessageFormat.create! :format => "{phone_number}.{slip_code}.{Field1}", 
                                                      :sector => Referral::MessageFormat::TYPE_HC
                                                    
      Referral::ClinicReport.create! :slip_code => "KPS001100"                                              
      parser = Referral::HCParser.new({:text=>"09712345678.KPS001100", :sender => @user})
      parser.scan_slip_code("KPS001100")
      parser.options[:slip_code].should eq "KPS001100"
    end
    
  end
  
end
