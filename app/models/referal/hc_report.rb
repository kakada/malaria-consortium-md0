class Referal::HCReport < Referal::Report
  default_scope where(:type => "Referal::HCReport")
  
  # return an Array of Hashes
  def valid_alerts
    alerts = []
    body = translate_message_for(:referal_health_center_clinic)
    
    #if self.slip_code.blank?
    #  report = Referal::ClinicReport.find_by_slip_code self.slip_code
    #  alerts << report.sender.message(body)
    #end
    
    
    alerts += self.place.od.acknowledgemente(body)
    
    body = translate_message_for(:referal_health_center_health_center)
    alerts << self.sender.message(body)
    
    alerts
  end
end

