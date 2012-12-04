require 'spec_helper'

describe ReferalParser do
  before(:each) do
    @village = Village.make
    @user = User.make :user_name => "bopha",  :phone_number => "85597888123", :place => @village.od
    @message = "0971234567KPS001001123456"
  end
  
  it "should parse the phone_number" do 
    [
      {  :msg => "0971234567sr001001123456" , 
        :result => {:phone_number=>"0971234567", :od=>"sr", :code_number=>"001001", :health_center => "123456" } 
      },
      {  :msg => "012123456BTB001001000000" , 
        :result => {:phone_number=>"012123456", :od=>"BTB", :code_number=>"001001", :health_center => "000000" } 
      },
      {  :msg => "0975555555KPCHAM010100" , 
        :result => {:phone_number=>"0975555555", :od=>"KPCHAM", :code_number=>"010100", :health_center => nil  } 
      },
    ].each do |item|
      ref_parser = ReferalParser.new @user
      components = ref_parser.parse(item[:msg])
      components.should eq item[:result]
    end
  end
  
  it "should scan phone_number" do
    ref_parser = ReferalParser.new @user
    ref_parser.create_scanner @message
    components = ref_parser.scan_phone_number
    components.should eq "0971234567"
  end
  
  it "should scan od" do
    ref_parser = ReferalParser.new @user
    ref_parser.create_scanner @message
    ref_parser.move_to 10
    components = ref_parser.scan_od
    components.should eq "KPS"
  end
  
  it "should scan code_number" do
    ref_parser = ReferalParser.new @user
    ref_parser.create_scanner @message
    ref_parser.move_to 13
    components = ref_parser.scan_code_number
    components.should eq "001001"
  end
  
  it "should scan health_center" do
    ref_parser = ReferalParser.new @user
    ref_parser.create_scanner @message
    ref_parser.move_to 19
    components = ref_parser.scan_health_center
    components.should eq "123456"
  end
  
end
