namespace :admin do
  desc "Send alert falciparum notification reminder to VMW and HC"
  task :send_alert_pf_notification => :environment do
    AlertPfNotification.process
  end

  desc "Send alert falciparum/Mimix notification reminder to VMW and HC of report during date range"
  task :send_reminder_report_on_july_2012 => :environment do
  	start_date = Time.new(2012, 7, 1).to_s
  	end_date = Time.new(2012, 7, 31).to_s
  	AlertPfNotification.add_reminder_reports start_date, end_date
  end
end