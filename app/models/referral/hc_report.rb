class Referral::HCReport < Referral::Report
  default_scope where(:type => "Referral::HCReport")
  
  after_save :update_clinic_report
  # return an Array of Hashes
  
  def update_clinic_report
    if self.slip_code
      report_clinic = Referral::ClinicReport.not_ignored.find_by_slip_code self.slip_code
      if !report_clinic.nil?
        report_clinic.status = Referral::Report::REPORT_STATUS_CONFIRMED
        report_clinic.confirm_from = self.sender
        report_clinic.save
      end  
    end
  end
  
  def valid_alerts
    alerts = []
    body = translate_message_for(:referral_health_center_clinic)
    
    if self.slip_code.blank?
      report = Referral::ClinicReport.no_error.not_ignored.find_by_slip_code self.slip_code
      alerts << report.sender.message(body)
    end
    
    
    alerts += self.place.od.acknowledgemente(body)
    
    body = translate_message_for(:referral_health_center_health_center)
    alerts << self.sender.message(body)
    
    alerts
  end
end

