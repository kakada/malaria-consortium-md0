require "spec_helper"

describe VMWReport do
   before(:each) do
     Setting[:successful_mobile_village_report] = "mobile --- malaria : {malaria_type}, sex : {sex}, age : {age}, day : {day} "
     Setting[:successful_non_mobile_village_report] = "non mobile --- malaria : {malaria_type}, sex : {sex}, age : {age}, day : {day} "
     Setting[:single_village_case_template] = "test_result => {test_result}, malaria_type => {malaria_type},sex => {sex}, age => {age}, day => {day}, village => {village},contact_number => {contact_number}"
     Setting[:aggregate_village_cases_template] = " cases: {cases}, pfcases: {pf_cases},
       pv_cases => {pv_cases}, f_cases => {f_cases}, v_cases => {v_cases},m_cases => {m_cases}, village => {village}"
  end
   
   describe "human_readable" do
     it "should return readable message from :successful_mobile_village_report for mobile patient key " do
       report = VMWReport.make :mobile => true, :malaria_type => "F", :age => 27, :sex => "Female", :day => 28
       report.human_readable.should eq "mobile --- malaria : F, sex : Female, age : 27, day : 28 "                      
     end
     
    it "should return readable message from :successful_mobile_village_report for non mobile patient key " do
       report = VMWReport.make :mobile => false, :malaria_type => "F", :age => 27, :sex => "Female", :day => 28
       report.human_readable.should eq "non mobile --- malaria : F, sex : Female, age : 27, day : 28 "   
     end
   end
   
   it "should return single case message translated" do
     village = Village.make :name => "Kkkk"
     sender  = User.make :phone_number => "099123456", :place => village
    
     report = VMWReport.make :malaria_type => "F", :sex => "Female", :age => 20, :day => 28, :village => village, :place => village, :sender => sender
      
     report.single_case_message.should eq "test_result => Pf, malaria_type => F,sex => Female, age => 20, day => 28, village => Kkkk,contact_number => 099123456"
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

          village = Village.make :parent => hc11, :code => "00000001", :name => "Ponhea Krek"

          # sender user
          village_user = User.make :place => village, :phone_number => "012123456"

          #hc admin
          hc_user1     = User.make :place => hc11 ,   :phone_number => "012223457"
          hc_user2     = User.make :place => hc11 ,   :phone_number => "012223458"

          # Od admin
          od_user1 = User.make :place =>od1, :phone_number => "012323456"
          od_user2 = User.make :place =>od1, :phone_number => "012323457"
          od_user3 = User.make :place =>od1, :phone_number => "012323458"

          # template
          Setting[:successful_non_mobile_village_report] = "village: messsage has been sent "
          Setting[:single_village_case_template] =     "hc: single case"
          Setting[:aggregate_village_cases_template] = "od: aggregated"

          Threshold.create! :place => village, :place_class => Village.name, :value => 2

          report = VMWReport.make(:place => village, :sender => village_user)
          report = VMWReport.make(:place => village, :sender => village_user)

          alert_hc = [ {:to=>"sms://012223457", :body=>"hc: single case", :from=>"malariad0://system"}, 
                      {:to=>"sms://012223458", :body=>"hc: single case", :from=>"malariad0://system"} ]

          alert_od = [ {:to=>"sms://012323456", :body=>"od: aggregated", :from=>"malariad0://system"}, 
                      {:to=>"sms://012323457", :body=>"od: aggregated", :from=>"malariad0://system"}, 
                      {:to=>"sms://012323458", :body=>"od: aggregated", :from=>"malariad0://system"}]

          alert_village = {:to=>"sms://012123456", :body=>"village: messsage has been sent ", :from=>"malariad0://system"}

          alerts = alert_hc + alert_od + [alert_village]

          report.valid_alerts.should =~ alerts

      end

       it "should alert to health_center, sender but no od when no threshold reached" do

          od1 = OD.make :code => "0001"
          od2 = OD.make :code => "0002"

          hc11 = HealthCenter.make  :parent => od1, :code => "000001"
          hc12 = HealthCenter.make  :parent => od1, :code => "000002" 
          hc13 = HealthCenter.make  :parent => od1, :code => "000003" 

          hc21 = HealthCenter.make  :parent => od2, :code => "000011"
          hc22 = HealthCenter.make  :parent => od2, :code => "000012" 
          hc23 = HealthCenter.make  :parent => od2, :code => "000013" 
          hc24 = HealthCenter.make  :parent => od2, :code => "000014" 

          village = Village.make :parent => hc11, :code => "00000001", :name => "Ponhea Krek"

          # sender user
          village_user = User.make :place => village, :phone_number => "012123456"

          #hc admin
          hc_user1     = User.make :place => hc11 ,   :phone_number => "012223457"
          hc_user2     = User.make :place => hc11 ,   :phone_number => "012223458"

          # Od admin
          od_user1 = User.make :place =>od1, :phone_number => "012323456"
          od_user2 = User.make :place =>od1, :phone_number => "012323457"
          od_user3 = User.make :place =>od1, :phone_number => "012323458"

          # template
          Setting[:successful_non_mobile_village_report] = "village: messsage has been sent "
          Setting[:single_village_case_template] =     "hc: single case"
          Setting[:aggregate_village_cases_template] = "od: aggregated"

          Threshold.create! :place => village, :place_class => Village.name, :value => 10

          report = VMWReport.make(:place => village, :sender => village_user)
          report = VMWReport.make(:place => village, :sender => village_user)

          alert_hc = [ {:to=>"sms://012223457", :body=>"hc: single case", :from=>"malariad0://system"}, 
                      {:to=>"sms://012223458", :body=>"hc: single case", :from=>"malariad0://system"} ]

          alert_village = {:to=>"sms://012123456", :body=>"village: messsage has been sent ", :from=>"malariad0://system"}

          alerts = alert_hc +  [alert_village]

          report.valid_alerts.should =~ alerts

       end
     end
     
     describe "with no threshold" do
       it "should alert to health_center, sender and always alert to od" do
         od1 = OD.make :code => "0001"
          od2 = OD.make :code => "0002"

          hc11 = HealthCenter.make  :parent => od1, :code => "000001"
          hc12 = HealthCenter.make  :parent => od1, :code => "000002" 
          hc13 = HealthCenter.make  :parent => od1, :code => "000003" 

          hc21 = HealthCenter.make  :parent => od2, :code => "000011"
          hc22 = HealthCenter.make  :parent => od2, :code => "000012" 
          hc23 = HealthCenter.make  :parent => od2, :code => "000013" 
          hc24 = HealthCenter.make  :parent => od2, :code => "000014" 

          village = Village.make :parent => hc11, :code => "00000001", :name => "Ponhea Krek"

          # sender user
          village_user = User.make :place => village, :phone_number => "012123456"

          #hc admin
          hc_user1     = User.make :place => hc11 ,   :phone_number => "012223457"
          hc_user2     = User.make :place => hc11 ,   :phone_number => "012223458"

          # Od admin
          od_user1 = User.make :place =>od1, :phone_number => "012323456"
          od_user2 = User.make :place =>od1, :phone_number => "012323457"
          od_user3 = User.make :place =>od1, :phone_number => "012323458"

          # template
          Setting[:successful_non_mobile_village_report] = "village: messsage has been sent "
          Setting[:single_village_case_template] =     "hc: single case"
          Setting[:aggregate_village_cases_template] = "od: aggregated"

          report = VMWReport.make(:place => village, :sender => village_user)

          alert_hc = [ {:to=>"sms://012223457", :body=>"hc: single case", :from=>"malariad0://system"}, 
                       {:to=>"sms://012223458", :body=>"hc: single case", :from=>"malariad0://system"} ]

          alert_od = [ {:to=>"sms://012323456", :body=>"hc: single case", :from=>"malariad0://system"}, 
                       {:to=>"sms://012323457", :body=>"hc: single case", :from=>"malariad0://system"}, 
                       {:to=>"sms://012323458", :body=>"hc: single case", :from=>"malariad0://system"}]


          alert_village = {:to=>"sms://012123456", :body=>"village: messsage has been sent ", :from=>"malariad0://system"}

          alerts = alert_hc + alert_od + [alert_village]
          report.valid_alerts.should =~ alerts
       end
     end
   end
   
end