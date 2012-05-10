class ReportObserver < ActiveRecord::Observer
  observe :report

  def after_save(report)
    # user_id   : 1
    # send_date : 01/01/2012 00:00:00
    # status    : "SEND/SENT"
    # report_id : 1
    
    # Enable provinces for alert pf notification
    provinces = AlertPf.last.provinces
    puts provinces
    puts report.province.id.to_s
    puts provinces.include? report.province.id.to_s
    if report.malaria_type == "F" and report.error_message.nil?
      AlertPfNotification.add_reminder(report) if provinces.include? report.province.id.to_s
    end
  end
  
end
