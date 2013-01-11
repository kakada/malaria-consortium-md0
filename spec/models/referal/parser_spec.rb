require 'spec_helper'

describe Referal::Parser do
  before(:each) do
    od = OD.make :abbr => "KPS"
    user = User.make :user_name => "bopha",  :phone_number => "85597888123", :place => od
    @params = { :text => "0971234567KPS001001123456", :sender => user }
    @hc = HealthCenter.make :code => "123456"
    
    between    =  Referal::ConstraintType::Validator.get_validator("Between", *[10,80] )
    length     =  Referal::ConstraintType::Validator.get_validator("Length", 1 )
    collection = Referal::ConstraintType::Validator.get_validator("Collection", "F,M" )
    
    @fieldAge = Referal::Field.create! :position => 1, :meaning => "Age", :template => "Age" #Field1
    @fieldSex = Referal::Field.create! :position => 2, :meaning => "Sex", :template => "Sex" #Field2
    
    constraintAge = @fieldAge.constraints.build
    constraintAge.validator = between
    constraintAge.save
    
    constraintSex = @fieldSex.constraints.build
    constraintSex.validator = length
    constraintSex.save
    
    constraintCollection = @fieldSex.constraints.build
    constraintCollection.validator = collection
    constraintCollection.save
  end
  
  describe "scan dynamic format" do
    
    describe "with one constraint"  do
        it "should parse dynamic format" do
            #Referal::MessageFormat.create! :format => "{phone_number}.{code_number}.{Field1}.{Field2}"
            #@parser = Referal::Parser.new({:text=>"09712345678.001.25.M"})
            parser = Referal::Parser.new({})
            parser.scan_dynamic_format(30, "Field1")
            parser.options[:field1].should_not be_nil
            parser.options[:field1].should eq 30
        end

        it "should raise exception :invalid_validator for field that does not exist " do
            parser = Referal::Parser.new({})
            expect{ parser.scan_dynamic_format(30, "Fieldx") }.to raise_error(Exception, "invalid_validator")
        end

        it "should raise exception when value is not valid " do
            parser = Referal::Parser.new({})
            expect{ parser.scan_dynamic_format(120, "Field1") }.to raise_error(Exception, "Field1")
        end
    end
    
    describe "with many constraint" do
       it "should parse dynamic format" do
            parser = Referal::Parser.new({})
            parser.scan_dynamic_format('F', "Field2")
            parser.options[:field2].should_not be_nil
            parser.options[:field2].should eq "F"
        end

        it "should raise exception :invalid_validator for field that does not exist " do
            parser = Referal::Parser.new({})
            expect{ parser.scan_dynamic_format(30, "Fieldx") }.to raise_error(Exception, "invalid_validator")
        end

        it "should raise exception when value does not have valid length" do
            parser = Referal::Parser.new({})
            expect{ parser.scan_dynamic_format("F2", "Field2") }.to raise_error(Exception, "Field2")
        end
        
        it "should raise exception when value does not have valid value \in collection(F,M)" do
            parser = Referal::Parser.new({})
            expect{ parser.scan_dynamic_format("K", "Field2") }.to raise_error(Exception, "Field2")
        end
    end
  end
  
  describe "scan_messages" do
     it "should scan messages" do
      message_format = Referal::MessageFormat.create! :format => "{phone_number}.{code_number}.{Field1}.{Field2}", :sector => Referal::MessageFormat::TYPE_CLINIC
      
      parser = Referal::ClinicParser.new({:text=>"0971234567.001.25.M"})
      parser.message_format = message_format 
      parser.scan_messages 

      parser.options[:text].should eq "0971234567.001.25.M"
      parser.options[:phone_number].should eq "0971234567"
      parser.options[:code_number].should eq "001"
      parser.options[:field1].should eq "25"
      parser.options[:field2].should eq "M"
    end
    
    it "should raise error with msg when text item is more than format item" do
      message_format = Referal::MessageFormat.create! :format => "{phone_number}.{code_number}.{Field1}.{Field2}.{Field3}.{Field4}", :sector => Referal::MessageFormat::TYPE_CLINIC
      parser = Referal::ClinicParser.new({:text=>"0971234567.090.25.M"})
      expect{parser.scan_messages}.to raise_error(Exception, :field_mismatch_format.to_s) 
      parser.options[:phone_number].should eq "0971234567"
      parser.options[:code_number].should eq "090"
      parser.options[:field1].should eq "25"
      parser.options[:field2].should eq "M"
    end
    
  end
  
  describe "scan slip_code" do
    it "should scan od and return OD abbr" do
      ref_parser = Referal::Parser.new @params.merge(:text => "KPS001100")
      ref_parser.scan_slip_code "KPS001100"
      ref_parser.options[:od_name].should eq "KPS"
      ref_parser.options[:book_number].should eq "001"
      ref_parser.options[:code_number].should eq "100"
      ref_parser.options[:slip_code] = "KPS001100"
    end
    
    it "should raise error" do
      ref_parser = Referal::Parser.new @params.merge(:text => "KPS00")
      expect{ref_parser.scan_slip_code "KPS00"}.to raise_error(Exception, "referal_invalid_book_number")
      ref_parser.options[:od_name].should eq "KPS"
      ref_parser.options[:error].should eq true
      ref_parser.options[:error_message].should eq :referal_invalid_book_number
    end
    
    it "should raise error" do
      ref_parser = Referal::Parser.new @params.merge(:text => "KPS0011106")
      expect{ref_parser.scan_slip_code "KPS0011106"}.to raise_error(Exception, "referal_invalid_code_number")
      ref_parser.options[:od_name].should eq "KPS"
      ref_parser.options[:book_number].should eq "001"
    end
    
  end
  
  describe "scan od" do
    it "should scan od and return OD abbr" do
      ref_parser = Referal::Parser.new @params.merge(:text => "KPS001")
      ref_parser.scan_od "KPS"
      ref_parser.options[:od_name].should eq "KPS"
    end
    
    it "should raise exception" do
      ref_parser = Referal::Parser.new(@params.merge(:text => "1234"))
      expect{ref_parser.scan_od "1234" }.to raise_error(Exception, :referal_invalid_od.to_s)
    end
    
    it "should raise exception" do  
      ref_parser = Referal::Parser.new @params.merge(:text => "SRM001001")
      expect{ref_parser.scan_od "SRM"}.to raise_error(Exception, :referal_invalid_not_in_od.to_s)
    end
  end
  
  describe "scan book number" do
    it "should scan book number" do
      ref_parser = Referal::Parser.new @params.merge(:text => "001xxx")
      ref_parser.scan_book_number "001"
      ref_parser.options[:book_number].should eq "001"      
    end
    
    it "should raise exectpion with invalid book number" do
      ref_parser = Referal::Parser.new @params.merge(:text => "12zzz")
      expect{ref_parser.scan_book_number "12" }.to raise_error(Exception, :referal_invalid_book_number.to_s)
    end
  end
  
  describe "scan code_number" do
    it "should scan code_number" do
      ref_parser = Referal::Parser.new @params.merge(:text => "100")
      ref_parser.scan_code_number "100"
      ref_parser.options[:code_number].should eq "100"
    end
    
    it "should raise exception" do
      ref_parser = Referal::Parser.new @params.merge(:text => "xx1")
      expect{ref_parser.scan_code_number "xx1" }.to raise_error(Exception,:referal_invalid_code_number.to_s)
    end
  end
  
  describe "scan health center" do
    it "should scan health_center" do
      ref_parser = Referal::Parser.new(@params.merge(:text => "123456" ))
      ref_parser.scan_health_center "123456"
      ref_parser.options[:health_center_code].should eq "123456"
    end
    
    it "should scan health center with nil result" do
      ref_parser = Referal::Parser.new @params.merge(:text => "")
      ref_parser.scan_health_center ""
      ref_parser.options[:health_center_code].should eq nil
    end
    
    it "should raise exception with invalid healthcenter format " do
      ref_parser = Referal::Parser.new @params.merge(:text => "12345xx")
      expect{ref_parser.scan_health_center "12345xx"}.to raise_error(Exception, :referal_invalid_health_center_format.to_s)
    end
    
    it "should raise exception with invalid healthcenter code " do
      ref_parser = Referal::Parser.new @params.merge(:text => "123455")
      expect{ref_parser.scan_health_center "123455" }.to raise_error(Exception, :referal_invalid_health_center_code.to_s)
    end

  end
end
