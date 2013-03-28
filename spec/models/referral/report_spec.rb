require "spec_helper"

describe Referral::Report do
  before(:each) do
    @province = Province.make
    @od = @province.ods.make :code => "001122", :name => "Battambong", :abbr => "BTB"
    @health_center = @od.health_centers.make
    @village = @health_center.villages.make :code => '12345678'
    @health_center.villages.make :code => '87654321'

    @hc_user = @health_center.users.make :phone_number => "85581900000"
    @vmw_user = @village.users.make :phone_number => "85581910000"
    @od_user1 = @od.users.make :phone_number => "85581920000"
    @od_user2 = @od.users.make :phone_number => "85581930000"

    @valid_message = {:from => "sms://85581900000", :body => "F123M012345678"}
    @valid_vmw_message = {:from => "sms://85581910000", :body => "F123M0."}
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
      report = Referral::ClinicReport.create!(@valid_report_attr)
      report.slip_code.should eq "SRM001100"
    end
    
  end
  
  describe "create parser" do
    it "should create parser healthcenter parser" do
      parser = Referral::Report.create_parser(:sender => @hc_user)
      parser.class.should eq Referral::HCParser
    end
    
    it "should create clinic parser" do
      parser = Referral::Report.create_parser(:sender => @vmw_user)
      parser.class.should eq Referral::ClinicParser
    end
  end
  
  
  describe "template from key" do
    before(:each) do
      Setting[:Field1] = "this is a field"
      Setting[:Field2] = "xxx"
      Referral::Field.create!(:position => 1, :meaning => "Sex", :template => "Invalid format for sex{original_message}" )
    end
    
    it "should return template from the field table" do
       template = Referral::Report.template_from_key("Field1")
       template.should eq "Invalid format for sex{original_message}"
    end
    
    it "should return template from Setting" do
       template = Referral::Report.template_from_key("Field2")
       template.should eq "xxx"
    end
    
    it "should return empty template when not existing in 5 fields and setting template" do
       template = Referral::Report.template_from_key("no_existed")
       template.should eq ""
    end
  end
  
  describe "translate message for a key template" do
    it "should translate correctly" do
      report = Referral::Report.new  :phone_number     => "85512123456",
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
    report = Referral::Report.create!:phone_number => "012123456",
                                    :place => @od,
                                    :slip_code        => "001001" ,
                                    :book_number      => "001",
                                    :code_number      => "001",
                                    :text => "xxx xxx xxx",
                                    :error => true,
                                    :sender => @od_user1,
                                    :error_message => "invalid_code"
    messages = report.error_alert          
    messages.should eq :to=>"sms://85581920000", :body=>"You have sent an invalid message: xxx xxx xxx" , :from => MessageProxy.app_name
  end
  
  describe "generate_alert" do
    it "should invoke error_alert when report error" do
      report = Referral::ClinicReport.create! :error => true
      report.should_receive(:error_alert).once
      report.generate_alerts
    end
    
    it "should invoke valid_alerts when no error for report" do
      report = Referral::ClinicReport.create! :error => false
      report.should_receive(:valid_alerts).once
      report.generate_alerts
    end
  end
  
  describe "duplicated_per_sender" do
    it "should return duplicated report" do
      v1 = Village.make
      v2 = Village.make
      
      sender1 = User.make :place => v1
      sender2 = User.make :place => v2

      
      r1 = Referral::Report.create!(:text => "KPC001001", :sender => sender1)
      r2 = Referral::Report.create!(:text => "KPC001002", :sender => sender1)
      r3 = Referral::Report.create!(:text => "KPC001003", :sender => sender1)
      
      r4 = Referral::Report.create!(:text => "KPC001001", :sender => sender1, :ignored => true)
      
      r5 = Referral::Report.create!(:text => "KPC001002", :sender => sender1)
      r6 = Referral::Report.create!(:text => "KPC001001", :sender => sender1)
      
      r7  = Referral::Report.create!(:text => "KPC001001", :sender => sender2)
      r8  = Referral::Report.create!(:text => "KPC001002", :sender => sender2)
      r9  = Referral::Report.create!(:text => "KPC001003", :sender => sender2)
      r10 = Referral::Report.create!(:text => "KPC001004", :sender => sender2)
      r11 = Referral::Report.create!(:text => "KPC001005", :sender => sender2)
      r12 = Referral::Report.create!(:text => "KPC001006", :sender => sender2)
      
      r13 = Referral::Report.create!(:text => "KPC001007", :sender => sender2)
      r14 = Referral::Report.create!(:text => "KPC001007", :sender => sender1)
      
      r15 = Referral::Report.create!(:text => "KPC001008", :sender => sender2)
      r16 = Referral::Report.create!(:text => "KPC001008", :sender => sender2)
      r17 = Referral::Report.create!(:text => "KPC001008", :sender => sender2)
      
      r18 = Referral::Report.create!(:text => "KPC001009", :sender => sender2, :ignored => true)
      r18 = Referral::Report.create!(:text => "KPC001009", :sender => sender2, :ignored => true)
      r18 = Referral::Report.create!(:text => "KPC001009", :sender => sender2, :ignored => true )
      
      reports = Referral::Report.duplicated_per_sender
      
      duplicates = [ r17, r16, r15, r6, r5, r2, r1]
        
      reports.each_with_index do |report, index|
        report.should  eq duplicates[index] 
      end
      
    end
  end
end