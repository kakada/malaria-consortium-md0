class VMWReport < Report
  default_scope where(:type => "VMWReport")

  def human_readable
    key  = mobile ? :successful_mobile_village_report : :successful_non_mobile_village_report

    body = Setting[key].apply :test_result => get_full_malaria_type, 
                       :malaria_type => malaria_type, 
                       :age => age, 
                       :sex => sex, 
                       :day => day

    body
  end
  
  
  def valid_alerts
    alerts = []
    msg_body = single_case_message
    
    # Always notify the HC about the new case (TODO: what if it's already a HC report?)
    alert_health_center = health_center.create_alerts(msg_body, :except => sender)
    
    alerts += alert_health_center
    village_threshold = Threshold.find_for village
    

    
    if(village_threshold)
       if village.reports_reached_threshold(village_threshold)
          self.trigger_to_od =  true
          alert_od = od.create_alerts village.aggregate_report(Time.last_week) 
          alerts +=  alert_od
       end
     else
       
       self.trigger_to_od =  true
       alert_od = od.create_alerts msg_body
       alerts += alert_od
     end
    
    # alert to himself
    alert_village = self.sender.message(human_readable)
    alerts += [alert_village]
    alerts
  end

  def single_case_message
    template_values = {
      :test_result => get_full_malaria_type,
      :malaria_type => malaria_type,
      :sex => sex,
      :age => age,
      :day => day,
      :village => village.name,
      :contact_number => sender.phone_number
    }
    body = Setting[:single_village_case_template].apply(template_values)
    body
  end
end
