require "spec_helper"
describe HealthCenterReport do
  it "should return readable message from :successful_mobile_village_report for mobile patient key " do
    Setting[:successful_health_center_report] = "malaria : {malaria_type}, sex : {sex}, age : {age}, day : {day} "

    report = HealthCenterReport.make :mobile => true, :malaria_type => "F", :age => 27, :sex => "Female", :day => 28
    report.human_readable.should eq "malaria : F, sex : Female, age : 27, day : 28 "
  end
   
  it "should return single case message translated" do
     hc = HealthCenter.make :name => "Kkkk"
     sender = User.make :phone_number => "099123456", :place => hc
     
     
    
     report = HealthCenterReport.make :malaria_type => "F", :sex => "Female", :age => 20,
      :day => 28, :place => hc, :sender => sender
      
     Setting[:single_hc_case_template] = "hc :{health_center}, test_result => {test_result}, malaria_type => {malaria_type},sex => {sex}, age => {age}, day => {day}, village => {village},contact_number => {contact_number}"
    
     
     report.single_case_message.should eq "hc :Kkkk, test_result => Pf, malaria_type => F,sex => Female, age => 20, day => 28, village => #{report.village.name},contact_number => 099123456"
  end
  
  describe "valid_alert" do
     before(:each) do
        
     end
     
     describe "with threshold" do
       it "should alert to health_center, sender and od when reach threshold " do
          od1 = OD.make :code => "0001"
          od2 = OD.make :code => "0002"

          hc11 = HealthCenter.make  :parent => od1, :code => "000001"
          hc12 = HealthCenter.make  :parent => od1, :code => "000002" 
          hc13 = HealthCenter.make  :parent => od1, :code => "000003" 

          hc21 = HealthCenter.make  :parent => od2, :code => "000011"
          hc22 = HealthCenter.make  :parent => od2, :code => "000012" 
          hc23 = HealthCenter.make  :parent => od2, :code => "000013" 
          hc24 = HealthCenter.make  :parent => od2, :code => "000014" 

          #hc admin
          hc_user1     = User.make :place => hc11 ,   :phone_number => "012223457"
          hc_user2     = User.make :place => hc11 ,   :phone_number => "012223458"

          # Od admin
          od_user1 = User.make :place =>od1, :phone_number => "012323456"
          od_user2 = User.make :place =>od1, :phone_number => "012323457"
          od_user3 = User.make :place =>od1, :phone_number => "012323458"

          # template
          Setting[:single_hc_case_template] = "hc: message sent"
          Setting[:aggregate_hc_cases_template] = "hc: aggregate report"
          Setting[:successful_health_center_report] = "hc: send back"

          Threshold.create! :place => hc11, :place_class => "HealthCenter", :value => 2

          report = HealthCenterReport.make(:place => hc11, :sender => hc_user1)
          report = HealthCenterReport.make(:place => hc11, :sender => hc_user1)

          alert_hc = [{:to=>"sms://012223458", :body=>"hc: message sent", :from=>"malariad0://system"}]

          alert_od = [{:to=>"sms://012323456", :body=>"hc: aggregate report", :from=>"malariad0://system"}, 
                      {:to=>"sms://012323457", :body=>"hc: aggregate report", :from=>"malariad0://system"}, 
                      {:to=>"sms://012323458", :body=>"hc: aggregate report", :from=>"malariad0://system"}]

          alert_sender = {:to=>"sms://012223457", :body=>"hc: send back", :from=>"malariad0://system"}
          alerts = alert_hc + alert_od + [alert_sender]

          report.valid_alerts.should =~ alerts

       end
       it "should alert to health_center, sender and but not od when threshold does not reach" do
          od1 = OD.make :code => "0001"
          od2 = OD.make :code => "0002"

          hc11 = HealthCenter.make  :parent => od1, :code => "000001"
          hc12 = HealthCenter.make  :parent => od1, :code => "000002" 
          hc13 = HealthCenter.make  :parent => od1, :code => "000003" 

          hc21 = HealthCenter.make  :parent => od2, :code => "000011"
          hc22 = HealthCenter.make  :parent => od2, :code => "000012" 
          hc23 = HealthCenter.make  :parent => od2, :code => "000013" 
          hc24 = HealthCenter.make  :parent => od2, :code => "000014" 

          #hc admin
          hc_user1     = User.make :place => hc11 ,   :phone_number => "012223457"
          hc_user2     = User.make :place => hc11 ,   :phone_number => "012223458"

          # Od admin
          od_user1 = User.make :place =>od1, :phone_number => "012323456"
          od_user2 = User.make :place =>od1, :phone_number => "012323457"
          od_user3 = User.make :place =>od1, :phone_number => "012323458"

          # template
          Setting[:single_hc_case_template] = "hc: message sent"
          Setting[:aggregate_hc_cases_template] = "hc: aggregate report"
          Setting[:successful_health_center_report] = "hc: send back"

          Threshold.create! :place => hc11, :place_class => "HealthCenter", :value => 100

          report = HealthCenterReport.make(:place => hc11, :sender => hc_user1)
          report = HealthCenterReport.make(:place => hc11, :sender => hc_user1)

          alert_hc = [{:to=>"sms://012223458", :body=>"hc: message sent", :from=>"malariad0://system"}]

          alert_sender = {:to=>"sms://012223457", :body=>"hc: send back", :from=>"malariad0://system"}
          alerts = alert_hc + [alert_sender]

          report.valid_alerts.should =~ alerts

        end
     end
     
     describe "without threshold" do
       it "should always alert to health_center, sender and od " do
          od1 = OD.make :code => "0001"
          od2 = OD.make :code => "0002"

          hc11 = HealthCenter.make  :parent => od1, :code => "000001"
          hc12 = HealthCenter.make  :parent => od1, :code => "000002" 
          hc13 = HealthCenter.make  :parent => od1, :code => "000003" 

          hc21 = HealthCenter.make  :parent => od2, :code => "000011"
          hc22 = HealthCenter.make  :parent => od2, :code => "000012" 
          hc23 = HealthCenter.make  :parent => od2, :code => "000013" 
          hc24 = HealthCenter.make  :parent => od2, :code => "000014" 

          #hc admin
          hc_user1     = User.make :place => hc11 ,   :phone_number => "012223457"
          hc_user2     = User.make :place => hc11 ,   :phone_number => "012223458"

          # Od admin
          od_user1 = User.make :place =>od1, :phone_number => "012323456"
          od_user2 = User.make :place =>od1, :phone_number => "012323457"
          od_user3 = User.make :place =>od1, :phone_number => "012323458"

          # template
          Setting[:single_hc_case_template] = "hc: message sent"
          Setting[:aggregate_hc_cases_template] = "hc: aggregate report"
          Setting[:successful_health_center_report] = "hc: send back"

          report = HealthCenterReport.make(:place => hc11, :sender => hc_user1)
          report = HealthCenterReport.make(:place => hc11, :sender => hc_user1)

            
          alert_hc = [{:to=>"sms://012223458", :body=>"hc: message sent", :from=>"malariad0://system"}]
          
          alert_od = [{:to=>"sms://012323456", :body=>"hc: message sent", :from=>"malariad0://system"}, 
                      {:to=>"sms://012323457", :body=>"hc: message sent", :from=>"malariad0://system"}, 
                      {:to=>"sms://012323458", :body=>"hc: message sent", :from=>"malariad0://system"}]
                    
          alert_sender = {:to=>"sms://012223457", :body=>"hc: send back", :from=>"malariad0://system"}

        
          alerts = alert_hc + alert_od + [alert_sender]

          report.valid_alerts.should =~ alerts

       end
     end
     
     
  end

       
  
  
  
end