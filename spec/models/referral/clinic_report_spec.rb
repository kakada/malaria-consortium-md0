require "spec_helper"

describe Referral::ClinicReport do
  before(:each) do
    @province = Province.make
    @od = @province.ods.make :abbr => "BDB", :name => "BatDamBong", :code => "123456"
    
    
    
    @hc1 = @od.health_centers.make :name => "hc1", :code => "12345678"
    @hc2 = @od.health_centers.make :name => "hc2"
    @hc3 = @od.health_centers.make :name => "hc3"
    @hc4 = @od.health_centers.make :name => "hc4"
    
    @hc_user11 = @hc1.users.make :phone_number => "85581900000", :apps => [User::APP_REFERAL], :status => true
    @hc_user12 = @hc1.users.make :phone_number => "85581910000", :apps => [User::APP_REFERAL, User::APP_MDO], :status => true
    @hc_user13 = @hc1.users.make :phone_number => "85581920000", :apps => [User::APP_REFERAL], :status => false
    @hc_user14 = @hc1.users.make :phone_number => "85581930000", :apps => [User::APP_MDO], :status => true
    
    @hc_user21 = @hc2.users.make :phone_number => "85581800000", :apps => [User::APP_REFERAL], :status => true
    @hc_user22 = @hc2.users.make :phone_number => "85581810000", :apps => [User::APP_REFERAL, User::APP_MDO], :status => true
    @hc_user23 = @hc2.users.make :phone_number => "85581820000", :apps => [User::APP_REFERAL], :status => false
    @hc_user24 = @hc2.users.make :phone_number => "85581830000", :apps => [User::APP_MDO], :status => true
    
    @od_user1 = @od.users.make :phone_number => "85581950000", :apps => [User::APP_REFERAL], :status => true
    @od_fac_enabled = @od.users.make :phone_number  => "855819000000", :apps => [User::APP_REFERAL], :status => true,  :role => User::ROLE_REF_FACILITATOR
    @od_fac_disabled = @od.users.make :phone_number => "855819010000", :apps => [User::APP_REFERAL], :status => false, :role => User::ROLE_REF_FACILITATOR
    @od_fac_disabled = @od.users.make :phone_number => "855819020000", :apps => [User::APP_REFERAL], :status => true,  :role => User::ROLE_REF_FACILITATOR
    
    @v1 = @hc1.villages.make :name =>"ToulSomRoungVillage", :code => "10101010"
    @v_user1 = @v1.users.make :phone_number => "85590909090", :apps => [User::APP_REFERAL], :status => true
    
    @od_user2 = @od.users.make :phone_number => "85581960000"

    @valid_message = {:from => "sms://85581920000", :body => "F123M012345678", :guid => "123456"}
  end
  
  describe "Valid report" do
    
    it "should alert only to all users in specified in the reference health center " do
     Setting[:referral_clinic_health_center] = "You receive a patient {phone_number} from {place} with {slip_code}"
     Setting[:referral_clinic_clinic]        = "You have sent patient {phone_number} to {health_center} with {slip_code}" 
     Setting[:referral_clinic_facilitator]   = "Patient has been refered to {health_center} with {slip_code}" 
     
     report = Referral::ClinicReport.create! :phone_number          => "012123456",
                                            :place                 => @v1 ,
                                            :send_to_health_center => @hc1 ,
                                            :sender                => @v_user1 ,
                                            :slip_code             => "001001" ,
                                            :book_number           => "001",
                                            :code_number           => "001",
                                            :text                  => "xxx xxx xxx"
     messages = report.valid_alerts

     messages.should =~     
      [
        {:to=>"sms://85581900000", :body=>"You receive a patient 012123456 from 10101010 ToulSomRoungVillage (Village) with 001001", :from=>"malariad0://system"}, 
        {:to=>"sms://85581910000", :body=>"You receive a patient 012123456 from 10101010 ToulSomRoungVillage (Village) with 001001", :from=>"malariad0://system"}, 
        {:to=>"sms://855819000000", :body=>"Patient has been refered to 12345678 - hc1 with 001001", :from=>"malariad0://system"}, 
        {:to=>"sms://855819020000", :body=>"Patient has been refered to 12345678 - hc1 with 001001", :from=>"malariad0://system"}, 
        {:to=>"sms://85590909090", :body=>"You have sent patient 012123456 to 12345678 - hc1 with 001001", :from=>"malariad0://system"}
        ]
    end
    
    it "should send to all users in all health centers under the od, all facilitator under od and himself" do
      Setting[:referral_clinic_health_center] = "You receive a patient {phone_number} from {place} with {slip_code}"
      Setting[:referral_clinic_clinic]        = "You have sent patient {phone_number} with {slip_code}"
      Setting[:referral_clinic_facilitator]   = "Patient has been refered to {health_center} with {slip_code}" 
      
      report = Referral::ClinicReport.create! :phone_number          => "012123456",
                                            :place                 => @v1 ,
                                            :send_to_health_center => nil ,
                                            :sender                => @v_user1 ,
                                            :slip_code             => "001001" ,
                                            :book_number           => "001",
                                            :code_number           => "001",
                                            :text                  => "xxx xxx xxx"
      messages = report.valid_alerts
      
      messages.should =~ [
        {:to=>"sms://85581900000", :body=>"You receive a patient 012123456 from 10101010 ToulSomRoungVillage (Village) with 001001", :from=>"malariad0://system"}, 
        {:to=>"sms://85581910000", :body=>"You receive a patient 012123456 from 10101010 ToulSomRoungVillage (Village) with 001001", :from=>"malariad0://system"}, 
        {:to=>"sms://85581800000", :body=>"You receive a patient 012123456 from 10101010 ToulSomRoungVillage (Village) with 001001", :from=>"malariad0://system"}, 
        {:to=>"sms://85581810000", :body=>"You receive a patient 012123456 from 10101010 ToulSomRoungVillage (Village) with 001001", :from=>"malariad0://system"}, 
        {:to=>"sms://855819000000", :body=>"Patient has been refered to ?? with 001001", :from=>"malariad0://system"}, 
        {:to=>"sms://855819020000", :body=>"Patient has been refered to ?? with 001001", :from=>"malariad0://system"}, 
        {:to=>"sms://85590909090", :body=>"You have sent patient 012123456 with 001001", :from=>"malariad0://system"}
        ]
    end
  end
end