class HealthCenterReport < Report
  default_scope where(:type => "HealthCenterReport")

  def human_readable
    Setting[:successful_health_center_report].apply :test_result => get_full_malaria_type,
                                                    :malaria_type => malaria_type,
                                                    :age => age,
                                                    :sex => sex,
                                                    :day => day,
                                                    :village_code => village.nil? ? "" : village.code
  end
  
  def valid_alerts
    alerts = []
    msg_body = single_case_message
    
    # Always notify the HC about the new case (TODO: what if it's already a HC report?)
    alert_health_center = health_center.create_alerts(msg_body, :except => sender)
    
    alerts += alert_health_center
    
    hc_threshold = Threshold.find_for health_center
    if hc_threshold
       if health_center.reports_reached_threshold hc_threshold
         self.trigger_to_od =  true
         alert_od = od.create_alerts(health_center.aggregate_report(Time.last_week))
         alerts +=  alert_od
       end
    else
       self.trigger_to_od =  true
       alert_od = od.create_alerts msg_body
       alerts += alert_od
    end
    
    # alert to himself
    alert_hc = self.sender.message(human_readable)
    alerts += [alert_hc]
    alerts
  end  

  def single_case_message
    template_values = {
      :test_result => get_full_malaria_type,
      :malaria_type => malaria_type,
      :sex => sex,
      :age => age,
      :day => day,
      :village => village.nil? ? "" : village.name,
      :contact_number => sender.phone_number,
      :health_center => sender.place.name
    }
    Setting[:single_hc_case_template].apply(template_values)
  end
end
