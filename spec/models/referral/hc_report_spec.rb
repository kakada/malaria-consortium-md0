require "spec_helper"

describe Referral::HCReport do
  before(:each) do
    @province = Province.make
    @od = @province.ods.make :abbr => "BDB", :name => "BatDamBong", :code => "123456"
    
    @hc1 = @od.health_centers.make :name => "hc1", :code => "12345678"
    @hc2 = @od.health_centers.make :name => "hc2"
    @hc3 = @od.health_centers.make :name => "hc3"
    @hc4 = @od.health_centers.make :name => "hc4"
    
    @v1  = @hc1.villages.make :name => "v1", :code => "1010101010"
    
    @v_user1 = @v1.users.make :phone_number => "85581999", :apps => [User::APP_REFERAL], :status => true
    
    @hc_user11 = @hc1.users.make :phone_number => "8558190", :apps => [User::APP_REFERAL], :status => true
    @hc_user12 = @hc1.users.make :phone_number => "8558191", :apps => [User::APP_REFERAL, User::APP_MDO], :status => true
    @hc_user13 = @hc1.users.make :phone_number => "8558192", :apps => [User::APP_REFERAL], :status => false
    @hc_user14 = @hc1.users.make :phone_number => "8558193", :apps => [User::APP_MDO], :status => true
    
    @hc_user21 = @hc2.users.make :phone_number => "8558180", :apps => [User::APP_REFERAL], :status => true
    @hc_user22 = @hc2.users.make :phone_number => "8558181", :apps => [User::APP_REFERAL, User::APP_MDO], :status => true
    @hc_user23 = @hc2.users.make :phone_number => "8558182", :apps => [User::APP_REFERAL], :status => false
    @hc_user24 = @hc2.users.make :phone_number => "8558183", :apps => [User::APP_MDO], :status => true
    
    @od_user1 = @od.users.make :phone_number => "8558195", :apps => [User::APP_REFERAL], :status => true
    @od_user2 = @od.users.make :phone_number => "8558196"
    @od_user3 = @od.users.make :phone_number => "8558197", :apps => [User::APP_REFERAL,User::APP_MDO], :status => true
    
    @valid_message = {:from => "sms://8558192", :body => "F123M012345678", :guid => "123456"}
  end
  
  it "should return valid report" do
    Setting[:referral_health_center_clinic]        = "A msg from HC: {health_center} with Slip: {slip_code}"
    Setting[:referral_health_center_health_center] = "Your msg has been send to {od} with Slip: {slip_code} Original message: {original_message}"
    
    Referral::ClinicReport.create! :slip_code     => "100100", 
                                   :sender        => @v_user1,
                                   :code_number   => "100",
                                   :book_number   => "100"
                                 
    
    
    hc_report = Referral::HCReport.create! :place         => @hc1 ,
                                          :sender        => @hc_user21 ,
                                          :slip_code     => "100100",
                                          :code_number   => "100",
                                          :book_number   => "100",
                                          :text          => "xxx-xxx"
    messages = hc_report.valid_alerts 
    
    messages.should =~ [{:to=>"sms://85581999", :body=>"A msg from HC: 12345678 - hc1 with Slip: 100100", :from=>"malariad0://system"}, 
                        {:to=>"sms://8558180", :body=>"Your msg has been send to 123456 - BatDamBong with Slip: 100100 Original message: xxx-xxx", :from=>"malariad0://system"}
                       ]
  end
  
  describe "create" do
#    it "should raise error when clinic slip_code does not exist" do
#      hc_report = Referral::HCReport.new :slip_code => "KPS001001"
#      count = Referral::HCReport.count
#      
#      expect{hc_report.save}.to raise_error(Exception, "slip_code does not exist in clinic report")
#      Referral::HCReport.count.should eq count
#    end
    
    it "should save hc report when there is a clinic slip_code " do
      hc_report = Referral::HCReport.new :slip_code => "KPS001001", :sender => @hc_user22
      Referral::ClinicReport.create! :slip_code => "KPS001001"
      
      count = Referral::HCReport.count
      hc_report.save.should eq true
      
      Referral::HCReport.count.should eq count+1
      
      clinic_report = Referral::ClinicReport.find_by_slip_code "KPS001001"
      clinic_report.status.should eq Referral::Report::REPORT_STATUS_CONFIRMED
      clinic_report.confirm_from.should eq @hc_user22
    end
  end
end