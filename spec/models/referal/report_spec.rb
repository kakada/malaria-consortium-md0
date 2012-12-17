require "spec_helper"

describe Referal::Report do
  before(:each) do
    @province = Province.make
    @od = @province.ods.make :code => "001122", :name => "Battambong"
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
  
  describe "translate message for a key template" do
    it "should translate correctly" do
      report = Referal::Report.new  :phone_number => "012123456",
                                    :place => @od,
                                    :slip_code        => "001001" ,
                                    :book_number      => "001",
                                    :code_number      => "001",
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