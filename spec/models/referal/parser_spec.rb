require 'spec_helper'

describe Referal::Parser do
  before(:each) do
    od = OD.make :abbr => "KPS"
    user = User.make :user_name => "bopha",  :phone_number => "85597888123", :place => od
    @params = { :text => "0971234567KPS001001123456", :sender => user }
    @hc = HealthCenter.make :code => "123456"
  end
  
  
  
  describe "scan od" do
    it "should scan od and return OD abbr" do
      ref_parser = Referal::Parser.new @params.merge(:text => "KPS001")
      ref_parser.create_scanner
      ref_parser.scan_od
      ref_parser.options[:od_name].should eq "KPS"
    end
    
    it "should raise exception" do
      ref_parser = Referal::Parser.new(@params.merge(:text => "1234"))
      ref_parser.create_scanner
      expect{ref_parser.scan_od}.to raise_error(Exception, :referal_invalid_od.to_s)
    end
    
    it "should raise exception" do  
      ref_parser = Referal::Parser.new @params.merge(:text => "SRM001001")
      ref_parser.create_scanner 
      expect{ref_parser.scan_od}.to raise_error(Exception, :referal_invalid_not_in_od.to_s)
    end
  end
  
  describe "scan book number" do
    it "should scan book number" do
      ref_parser = Referal::Parser.new @params.merge(:text => "001xxx")
      ref_parser.create_scanner
      ref_parser.scan_book_number
      ref_parser.options[:book_number].should eq "001"
    end
    
    it "should raise exectpion with invalid book number" do
      ref_parser = Referal::Parser.new @params.merge(:text => "12zzz")
      ref_parser.create_scanner
      expect{ref_parser.scan_book_number}.to raise_error(Exception, :referal_invalid_book_number.to_s)
    end
  end
  
  describe "scan code_number" do
    it "should scan code_number" do
      ref_parser = Referal::Parser.new @params.merge(:text => "100")
      ref_parser.create_scanner 
      ref_parser.scan_code_number
      ref_parser.options[:code_number].should eq "100"
    end
    
    it "should raise exception" do
      ref_parser = Referal::Parser.new @params.merge(:text => "xx1")
      ref_parser.create_scanner 
      expect{ref_parser.scan_code_number}.to raise_error(Exception,:referal_invalid_code_number.to_s)
    end
  end
  
  describe "scan health center" do
    it "should scan health_center" do
      ref_parser = Referal::Parser.new(@params.merge(:text => "123456" ))
      ref_parser.create_scanner 
      ref_parser.scan_health_center
      ref_parser.options[:health_center_code].should eq "123456"
    end
    
    it "should scan health center with nil result" do
      ref_parser = Referal::Parser.new @params.merge(:text => "")
      ref_parser.create_scanner 
      ref_parser.scan_health_center
      ref_parser.options[:health_center_code].should eq nil
    end
    
    it "should raise exception with invalid healthcenter format " do
      ref_parser = Referal::Parser.new @params.merge(:text => "12345xx")
      ref_parser.create_scanner 
      expect{ref_parser.scan_health_center}.to raise_error(Exception, :referal_invalid_health_center_format.to_s)
    end
    
    it "should raise exception with invalid healthcenter code " do
      ref_parser = Referal::Parser.new @params.merge(:text => "123455")
      ref_parser.create_scanner 
      expect{ref_parser.scan_health_center}.to raise_error(Exception, :referal_invalid_health_center_code.to_s)
    end
    
    
  end
end
