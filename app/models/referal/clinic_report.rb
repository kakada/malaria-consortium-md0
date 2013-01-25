class Referal::ClinicReport < Referal::Report
  default_scope where(:type => "Referal::ClinicReport")
  
  # return an Array of hashes
  def valid_alerts
    
    alerts = []
    alert_hcs = []

    if self.send_to_health_center.nil?
       alert_hcs = self.place.health_centers
    else
       alert_hcs << self.send_to_health_center
    end
    
    alert_hcs.each do |hc|
      body = translate_message_for(:referal_clinic_health_center)
      alerts += hc.acknowledgemente(body)
    end
    
    body = translate_message_for(:referal_clinic_clinic)
    alerts << self.sender.message(body)
    alerts
  end
end

