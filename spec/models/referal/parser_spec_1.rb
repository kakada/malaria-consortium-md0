require 'spec_helper'

describe Referal::Parser do
  before(:each) do
    @od = OD.make :abbr => "KPS"
    @user = User.make :user_name => "bopha",  :phone_number => "85597888123", :place => @od
    @message = "0971234567KPS001001123456"
  end
  
  it "should parse message from clinic" do 
    [
      { :msg => "0971234567KPS001001123456" , 
        :result => {:phone_number=>"0971234567", :od_name=>"KPS", :code_number=>"001", :book_number => "001", :health_center_code => "123456" } 
      },
      { :msg => "012123456KPS001001000000" , 
        :result => {:phone_number=>"012123456",  :od_name=>"KPS", :code_number=>"001", :book_number => "001", :health_center_code => "000000" } 
      },
      { :msg => "0975555555KPS010100" , 
        :result => {:phone_number=>"0975555555", :od_name=>"KPS", :code_number=>"100", :book_number => "010", :health_center_code => nil  } 
      },
    ].each do |item|
      ref_parser = Referal::Parser.new :body => item[:msg], :sender => @user
      components = ref_parser.parse_clinic(item[:msg])
      components.should eq item[:result]
    end
  end
  
  it "should parse message from health_center" do
    [
      {  :msg => "KPS001001123456" , 
        :result => {:od_name=>"KPS", :code_number=>"001", :book_number => "001" } 
      },
      {  :msg => "KPS001001000000" , 
        :result => { :od_name=>"KPS", :code_number=>"001", :book_number => "001" } 
      },
      {  :msg => "KPS010100" , 
        :result => { :od_name=>"KPS", :code_number=>"100", :book_number => "010" } 
      },
    ].each do |item|
      ref_parser = ReferalParser.new @user
      components = ref_parser.parse_health_center(item[:msg])
      components.should eq item[:result]
    end
  end
  
  describe "scan phone_number" do
    it "should scan phone_number" do
      ref_parser = ReferalParser.new @user
      ref_parser.create_scanner @message
      components = ref_parser.scan_phone_number
      components.should eq "0971234567"
    end
    
    it "should raise exception" do
      ref_parser = ReferalParser.new @user
      ref_parser.create_scanner "09712345xxx"
      expect {
        ref_parser.scan_phone_number
      }.to raise_error
    end
    
    
  end
  
  describe "san od" do
    it "should scan od" do
      ref_parser = ReferalParser.new @user
      ref_parser.create_scanner @message
      ref_parser.move_to 10
      components = ref_parser.scan_od
      components.should eq "KPS"
    end
    
    it "should raise exception" do
      ref_parser = ReferalParser.new @user
      ref_parser.create_scanner "1239xxx"
      expect{components = ref_parser.scan_od}.to raise_error(Exception, "Invalid Od format")
      
    end
    
    it "should raise exception" do  
      ref_parser = ReferalParser.new @user
      ref_parser.create_scanner "SRM111"
      expect{ref_parser.scan_od}.to raise_error(Exception, "Invalid user is from OD KPS not SRM")
    end
  end
  
  describe "scan book number " do
    it "should scan book number" do
      ref_parser = ReferalParser.new @user
      ref_parser.create_scanner @message
      ref_parser.move_to 13
      ref_parser.scan_book_number.should eq "001"
    end
    
    it "should raise exectpion with invalid book number" do
      ref_parser = ReferalParser.new @user
      ref_parser.create_scanner "00x"
      expect{ref_parser.scan_book_number}.to raise_error
    end
    
  end
  
  describe "scan code_number" do
    it "should scan code_number" do
      ref_parser = ReferalParser.new @user
      ref_parser.create_scanner @message
      ref_parser.move_to 16
      components = ref_parser.scan_code_number
      components.should eq "001"
    end
    
    it "should raise exception" do
      ref_parser = ReferalParser.new @user
      ref_parser.create_scanner "x00"
      expect{ref_parser.scan_code_number}.to raise_error
    end
  end
  
  describe "scan health center" do
    it "should scan health_center" do
      ref_parser = ReferalParser.new @user
      ref_parser.create_scanner @message
      ref_parser.move_to 19
      components = ref_parser.scan_health_center
      components.should eq "123456"
    end
    
    it "should scan health center with nil result" do
      ref_parser = ReferalParser.new @user
      ref_parser.create_scanner ""
      components = ref_parser.scan_health_center
      components.should eq nil
    end
    
    it "should raise exception " do
      ref_parser = ReferalParser.new @user
      ref_parser.create_scanner "12345"
      expect{ref_parser.scan_health_center}.to raise_error
    end
    
  end
  
  
  
end
