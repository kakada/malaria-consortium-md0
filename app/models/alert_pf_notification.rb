class AlertPfNotification < ActiveRecord::Base
  belongs_to :user
  belongs_to :report

  validates_presence_of :user, :report, :send_date, :status

  STATUSES = {:pending => "PENDING", :sent => "SENT"}

  def self.add_reminder report
    users = []
    village = report.village
    users |= village.users.activated if not Setting[:village_reminder].nil? and Setting[:village_reminder] == "1"
    users |= village.health_center.users.activated if not Setting[:hc_reminder].nil? and Setting[:hc_reminder] == "1"
    users |= village.health_center.od.users.activated if not Setting[:od_reminder].nil? and Setting[:od_reminder] == "1"
    users |= village.health_center.od.province.users.activated if not Setting[:provincial_reminder].nil? and Setting[:provincial_reminder] == "1"
    users |= village.health_center.od.province.country.users.activated if not Setting[:national_reminder].nil? and Setting[:national_reminder] == "1"
    users |= User.get_admin_user if not Setting[:admin_reminder].nil? and Setting[:admin_reminder] == "1"

    send_date = report.created_at.to_date + Setting[:reminder_days].to_i.days
    users.each do |user|
      AlertPfNotification.create!(:user_id => user.id, :send_date => send_date, :status => STATUSES[:pending], :report_id => report.id)
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
    message = self.user.message(self.translate_params(Setting[:reminder_message]))
    nuntium = Nuntium.new_from_config
    token = nuntium.send_ao message
    # update token to alert for identified nuntium message id
    self.status = STATUSES[:sent]
    self.token = token
    self.save
    Rails.logger.info "====== Send alert notification of #{self} with body #{message} ======"
  end

  def translate_params message
    template_values = {
      :malaria_type => self.report.malaria_type,
      :phone_number => self.user.phone_number,
      :village => self.report.village.name,
      :health_center => self.report.health_center.name
    }
    message.apply(template_values)
  end

end