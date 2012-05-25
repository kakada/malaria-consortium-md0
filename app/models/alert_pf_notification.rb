class AlertPfNotification < ActiveRecord::Base
  belongs_to :user
  belongs_to :report

  validates_presence_of :user, :report, :send_date, :status

  STATUSES = {:pending => "PENDING", :sent => "SENT"}

  def self.add_reminder report
    users = self.get_responsible_users report
    self.create_notification users, report
  end
  
  def self.create_notification users, report
    send_date = report.created_at.to_date + Setting[:reminder_days].to_i.days
    users.each do |user|
      if AlertPfNotification.where(:user_id => user.id, :report_id => report.id, :send_date => send_date, :status => STATUSES[:pending]).count == 0
        template_message = Templates.get_reminder_template_message(user)
        alert = AlertPfNotification.new(:user_id => user.id, :send_date => send_date, :status => STATUSES[:pending], :report_id => report.id)
        alert.message = alert.translate_params(template_message)
        alert.save
      end
    end
  end
  
  def self.process
    Rails.logger.info "====================== Alert Pf Notification process start: #{Time.new} ======================"
    alerts = AlertPfNotification.where("send_date = '#{Date.today}' and status = '#{STATUSES[:pending]}'")
    alerts.each do |alert|
      alert.deliver_to_user
    end
  end

  def deliver_to_user
    nuntium = Nuntium.new_from_config
    token = nuntium.send_ao self.user.message(self.message)
    # update token to alert for identified nuntium message id
    self.status = STATUSES[:sent]
    self.token = token
    self.save
    Rails.logger.info "====== Send alert notification of #{self} with body #{message} ======"
  end
  
  def self.get_responsible_users report
    users = []
    users |= report.village.users.activated if not Setting[:village_reminder].nil? and Setting[:village_reminder] == "1"
    users |= report.village.health_center.users.activated if not Setting[:hc_reminder].nil? and Setting[:hc_reminder] == "1"
    users |= report.village.health_center.od.users.activated if not Setting[:od_reminder].nil? and Setting[:od_reminder] == "1"
    users |= report.village.health_center.od.province.users.activated if not Setting[:provincial_reminder].nil? and Setting[:provincial_reminder] == "1"
    users |= report.village.health_center.od.province.country.users.activated if not Setting[:national_reminder].nil? and Setting[:national_reminder] == "1"
    users |= User.get_admin_user if not Setting[:admin_reminder].nil? and Setting[:admin_reminder] == "1"
    users
  end
  
  def translate_params message
    vmw_users = self.report.village.users.map { |u| u.phone_number }
    template_values = {
      :original_message => self.report.text,
      :phone_number => vmw_users.join("/"),
      :village => self.report.village.name,
      :health_center => self.report.health_center.name
    }
    message.apply(template_values)
  end

end