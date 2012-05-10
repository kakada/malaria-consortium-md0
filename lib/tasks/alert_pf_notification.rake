namespace :admin do
  desc "Send alert falciparum notification reminder to VMW and HC"
  task :send_alert_pf_notification => :environment do
    AlertPfNotification.process
  end
end