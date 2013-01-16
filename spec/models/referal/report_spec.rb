require "spec_helper"

describe Referal::Report do
  before(:each) do
    @province = Province.make
    @od = @province.ods.make :code => "001122", :name => "Battambong", :abbr => "BTB"
    @health_center = @od.health_centers.make
    @village = @health_center.villages.make :code => '12345678'
    @health_center.villages.make :code => '87654321'

    @hc_user = @health_center.users.make :phone_number => "8558190"
    @vmw_user = @village.users.make :phone_number => "8558191"
    @od_user1 = @od.users.make :phone_number => "8558192"
    @od_user2 = @od.users.make :phone_number => "8558193"

    @valid_message = {:from => "sms://8558190", :body => "F123M012345678"}
    @valid_vmw_message = {:from => "sms://8558191", :body => "F123M0."}
  end
  
  describe "create report" do
    before(:each) do
      @valid_report_attr = {
        :book_number => "001",
        :code_number => "100",
        :od_name     => "SRM"
      }
    end
    
    it "should have slip_code combined by od_name, code_number and book_number" do
      report = Referal::ClinicReport.create!(@valid_report_attr)
      report.slip_code.should eq "SRM001100"
    end
    
  end
  
  describe "create parser" do
    it "should create parser healthcenter parser" do
      parser = Referal::Report.create_parser(:sender => @hc_user)
      parser.class.should eq Referal::HCParser
    end
    
    it "should create clinic parser" do
      parser = Referal::Report.create_parser(:sender => @od_user1)
      parser.class.should eq Referal::ClinicParser
    end
  end
  
  
  describe "template from key" do
    before(:each) do
      Setting[:Field1] = "this is a field"
      Setting[:Field2] = "xxx"
      Referal::Field.create!(:position => 1, :meaning => "Sex", :template => "Invalid format for sex{original_message}" )
    end
    
    it "should return template from the field table" do
       template = Referal::Report.template_from_key("Field1")
       template.should eq "Invalid format for sex{original_message}"
    end
    
    it "should return template from Setting" do
       template = Referal::Report.template_from_key("Field2")
       template.should eq "xxx"
    end
    
    it "should return empty template when not existing in 5 fields and setting template" do
       template = Referal::Report.template_from_key("no_existed")
       template.should eq ""
    end
  end
  
  describe "translate message for a key template" do
    it "should translate correctly" do
      report = Referal::Report.new  :phone_number     => "012123456",
                                    :place            => @od,
                                    :slip_code        => "BTB001001" ,
                                    :book_number      => "001",
                                    :code_number      => "001",
                                    :od_name          => "BTB",
                                    :text => "xxx xxx xxx"
      
      Setting[:error_x] = "Place: {place} with code_number: {code_number} book_number: {book_number} with original: {original_message}"
        
      message = report.translate_message_for :error_x
      message.should eq("Place: 001122 Battambong (Od) with code_number: 001 book_number: 001 with original: xxx xxx xxx")
    end
  end
  
  it "error_alert" do
    Setting[:invalid_code] = "You have sent an invalid message: {original_message}"
    report = Referal::Report.create!:phone_number => "012123456",
                                    :place => @od,
                                    :slip_code        => "001001" ,
                                    :book_number      => "001",
                                    :code_number      => "001",
                                    :text => "xxx xxx xxx",
                                    :error => true,
                                    :sender => @od_user1,
                                    :error_message => "invalid_code"
    messages = report.error_alert          
    messages.should eq :to=>"sms://8558192", :body=>"You have sent an invalid message: xxx xxx xxx" , :from => MessageProxy.app_name
  end
  
  describe "generate_alert" do
    it "should invoke error_alert when report error" do
      report = Referal::ClinicReport.create! :error => true
      report.should_receive(:error_alert).once
      report.generate_alerts
    end
    
    it "should invoke valid_alerts when no error for report" do
      report = Referal::ClinicReport.create! :error => false
      report.should_receive(:valid_alerts).once
      report.generate_alerts
    end
  end
  
  
end