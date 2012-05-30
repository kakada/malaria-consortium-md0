class ReportObserver < ActiveRecord::Observer
  observe :report

  def after_save(report)
    # Enable provinces for alert pf notification
    if report.valid_pf_case?
      unless report.ignored
        unless AlertPf.last.nil?
          provinces = AlertPf.last.provinces
          AlertPfNotification.add_reminder(report) if provinces.include?(report.province.id.to_s)
        end
      else
        AlertPfNotification.remove_reminder(report)
      end
    end
  end
  
end
