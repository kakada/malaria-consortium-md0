require 'spec_helper'

describe Referral::Parser do
  before(:each) do
    od = OD.make :abbr => "KPS"
    @hc_hc = od.health_centers.make
    @village_clinic = @hc_hc.villages.make
    
    user          = User.make :user_name => "bopha",  :phone_number => "85597888123", :place => od
    @user_clinic  = User.make  :place => @village_clinic, :phone_number => "85511111100"
    @user_hc      = User.make  :place => @hc_hc, :phone_number => "85522222200" 
    
    @params = { :text => "0971234567KPS001001123456", :sender => user }
    @hc = HealthCenter.make :code => "123456"
    
    
    between    =  Referral::ConstraintType::Validator.get_validator("Between", *[10,80] )
    length     =  Referral::ConstraintType::Validator.get_validator("Length", 1 )
    collection = Referral::ConstraintType::Validator.get_validator("Collection", "F,M" )
    
    @fieldAge = Referral::Field.create! :position => 1, :meaning => "Age", :template => "Age should be between 10 to 80" #Field1
    @fieldSex = Referral::Field.create! :position => 2, :meaning => "Sex", :template => "Sex" #Field2
    
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
            #Referral::MessageFormat.create! :format => "{phone_number}.{code_number}.{Field1}.{Field2}"
            #@parser = Referral::Parser.new({:text=>"09712345678.001.25.M"})
            parser = Referral::Parser.new({})
            parser.scan_dynamic_format(30, "Field1")
            parser.options[:field1].should eq 30
            parser.options[:meaning1].should eq "Age"
        end

        it "should raise exception :invalid_validator for field that does not exist " do
            parser = Referral::Parser.new({})
            expect{ parser.scan_dynamic_format(30, "Fieldx") }.to raise_error(Exception, "referral_invalid_validator")
        end

        it "should raise exception when value is not valid " do
            parser = Referral::Parser.new({})
            expect{ parser.scan_dynamic_format(120, "Field1") }.to raise_error(Exception, "Field1")
        end
    end
    
    describe "with many constraint" do
       it "should parse dynamic format" do
            parser = Referral::Parser.new({})
            parser.scan_dynamic_format('F', "Field2")
            parser.options[:field2].should_not be_nil
            parser.options[:field2].should eq "F"
        end

        it "should raise exception :invalid_validator for field that does not exist " do
            parser = Referral::Parser.new({})
            expect{ parser.scan_dynamic_format(30, "Fieldx") }.to raise_error(Exception, "referral_invalid_validator")
        end

        it "should raise exception when value does not have valid length" do
            parser = Referral::Parser.new({})
            expect{ parser.scan_dynamic_format("F2", "Field2") }.to raise_error(Exception, "Field2")
        end
        
        it "should raise exception when value does not have valid value in collection(F,M)" do
            parser = Referral::Parser.new({})
            expect{ parser.scan_dynamic_format("K", "Field2") }.to raise_error(Exception, "Field2")
        end
    end
  end
  
  describe "scan_messages" do
    describe "Clinic Message" do
      it "should scan messages clinic" do
        message_format = Referral::MessageFormat.create! :format => "{phone_number}.{code_number}.{Field1}.{Field2}", :sector => Referral::MessageFormat::TYPE_CLINIC

        parser = Referral::ClinicParser.new({:text=>"0971234567.001.25.M"})
        parser.message_format = message_format 
        parser.scan_messages 

        parser.options[:text].should eq "0971234567.001.25.M"
        parser.options[:phone_number].should eq "0971234567"
        parser.options[:code_number].should eq "001"
        parser.options[:field1].should eq "25"
        parser.options[:field2].should eq "M"
      end

      it "should raise error with msg when text item is more than format item" do
        message_format = Referral::MessageFormat.create! :format => "{phone_number}.{code_number}.{Field1}.{Field2}.{Field3}.{Field4}", :sector => Referral::MessageFormat::TYPE_CLINIC
        parser = Referral::ClinicParser.new({:text=>"0971234567.090.25.M"})
        expect{parser.scan_messages}.to raise_error(Exception, :referral_field_mismatch_format.to_s) 
        parser.options[:phone_number].should eq "0971234567"
        parser.options[:code_number].should eq "090"
        parser.options[:field1].should eq "25"
        parser.options[:field2].should eq "M"
      end
    end
    describe "HealthCenter Message" do
      it "should scan message health_center " do
        message_format = Referral::MessageFormat.create! :format => "{slip_code}", :sector => Referral::MessageFormat::TYPE_HC
        
        Referral::ClinicReport.create! :slip_code => "KPS001001"  
        parser = Referral::HCParser.new({:text=>"KPS001001", :sender => @user_hc})
        parser.message_format = message_format 
        parser.scan_messages 

        parser.options[:sender].should eq @user_hc
        parser.options[:slip_code].should eq "KPS001001"
        parser.options[:book_number].should eq "001"
        parser.options[:code_number].should eq "001"
        parser.options[:od_name].should eq "KPS" 
      end
    end
    
    
  end
  
  describe "scan_phone_number" do
    describe "valid phone_number" do
      it "should accept empty and 0 phonenumber" do
        
        ["","0"].each do |phone_number|
           ref_parser = Referral::Parser.new({})
           ref_parser.scan_phone_number(phone_number).should eq phone_number
           ref_parser.options[:phone_number].should eq phone_number
        end
      end
      
      it "should accept only 9,10 digit-phone number " do
         ["012123456", "0971234567"].each do |phone_number|
           ref_parser = Referral::Parser.new({})
           ref_parser.scan_phone_number(phone_number).should eq phone_number
           ref_parser.options[:phone_number].should eq phone_number
         end
      end
    end
    
    describe "invalid phone_number" do
      it "should accept only empty, 0 , and 9-10 character phone_number only" do
        ["01112345", "016222"].each do |number|
          ref_parser = Referral::Parser.new({})
          expect{ ref_parser.scan_phone_number(number)}.to raise_error(Exception, "referral_invalid_phone_number")
        end
      end
    end
  end
  
  describe "scan slip_code" do
    it "should scan od and return OD abbr" do
      ref_parser = Referral::Parser.new @params.merge(:text => "KPS001100")
      ref_parser.scan_slip_code "KPS001100"
      ref_parser.options[:od_name].should eq "KPS"
      ref_parser.options[:book_number].should eq "001"
      ref_parser.options[:code_number].should eq "100"
      ref_parser.options[:slip_code] = "KPS001100"
    end
    
    it "should raise error" do
      ref_parser = Referral::Parser.new @params.merge(:text => "KPS00")
      expect{ref_parser.scan_slip_code "KPS00"}.to raise_error(Exception, "referral_invalid_book_number")
      ref_parser.options[:od_name].should eq "KPS"
      ref_parser.options[:error].should eq true
      ref_parser.options[:error_message].should eq :referral_invalid_book_number
    end
    
    it "should raise error" do
      ref_parser = Referral::Parser.new @params.merge(:text => "KPS0011106")
      expect{ref_parser.scan_slip_code "KPS0011106"}.to raise_error(Exception, "referral_invalid_code_number")
      ref_parser.options[:od_name].should eq "KPS"
      ref_parser.options[:book_number].should eq "001"
    end
    
  end
  
  describe "scan od" do
    it "should scan od and return OD abbr" do
      ref_parser = Referral::Parser.new @params.merge(:text => "KPS001")
      ref_parser.scan_od "KPS"
      ref_parser.options[:od_name].should eq "KPS"
    end
    
    it "should raise exception" do
      ref_parser = Referral::Parser.new(@params.merge(:text => "1234"))
      expect{ref_parser.scan_od "1234" }.to raise_error(Exception, :referral_invalid_od.to_s)
    end
    
    it "should raise exception" do  
      ref_parser = Referral::Parser.new @params.merge(:text => "SRM001001")
      expect{ref_parser.scan_od "SRM"}.to raise_error(Exception, :referral_invalid_not_in_od.to_s)
    end
  end
  
  describe "scan book number" do
    it "should scan book number" do
      ref_parser = Referral::Parser.new @params.merge(:text => "001xxx")
      ref_parser.scan_book_number "001"
      ref_parser.options[:book_number].should eq "001"      
    end
    
    it "should raise exectpion with invalid book number" do
      ref_parser = Referral::Parser.new @params.merge(:text => "12zzz")
      expect{ref_parser.scan_book_number "12" }.to raise_error(Exception, :referral_invalid_book_number.to_s)
    end
  end
  
  describe "scan code_number" do
    it "should scan code_number" do
      ref_parser = Referral::Parser.new @params.merge(:text => "100")
      ref_parser.scan_code_number "100"
      ref_parser.options[:code_number].should eq "100"
    end
    
    it "should raise exception" do
      ref_parser = Referral::Parser.new @params.merge(:text => "xx1")
      expect{ref_parser.scan_code_number "xx1" }.to raise_error(Exception,:referral_invalid_code_number.to_s)
    end
  end
  
  describe "scan health center" do
    it "should scan health_center" do
      ref_parser = Referral::Parser.new(@params.merge(:text => "123456" ))
      ref_parser.scan_health_center "123456"
      ref_parser.options[:health_center_code].should eq "123456"
    end
    
    it "should scan health center with nil result" do
      ref_parser = Referral::Parser.new @params.merge(:text => "")
      ref_parser.scan_health_center ""
      ref_parser.options[:health_center_code].should eq nil
    end
    
    it "should raise exception with invalid healthcenter format " do
      ref_parser = Referral::Parser.new @params.merge(:text => "12345xx")
      expect{ref_parser.scan_health_center "12345xx"}.to raise_error(Exception, :referral_invalid_health_center_format.to_s)
    end
    
    it "should raise exception with invalid healthcenter code " do
      ref_parser = Referral::Parser.new @params.merge(:text => "123455")
      expect{ref_parser.scan_health_center "123455" }.to raise_error(Exception, :referral_invalid_health_center_code.to_s)
    end
  end
  
  describe "split_term" do
    it "should return 5-element array " do
       Referral::Parser.split_term("..a.b.", ".").should eq ["", "", "a", "b", ""]
    end
    
    it "should return an element array " do
       Referral::Parser.split_term("", ".").should eq [""]
    end
    
    it "should return 2 empty string" do
       Referral::Parser.split_term(".", ".").should eq ["",""]
    end
    
    it "should return 2 empty string" do
       Referral::Parser.split_term("a.b", ".").should eq ["a","b"]
    end
  end
end
