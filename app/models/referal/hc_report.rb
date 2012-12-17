class Referal::HCReport < Referal::Report
  default_scope where(:type => "Referal::HCReport")
  
  # return an Array of Hashes
  def valid_alerts
    alerts = []
    
    body = translate_message_for(:referal_health_center_clinic)
    alerts += self.place.od.acknowledgemente(body)
    
    body = translate_message_for(:referal_health_center_health_center)
    alerts << self.sender.message(body)
    alerts
  end
end

