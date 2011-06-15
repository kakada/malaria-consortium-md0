class OD < Place
  alias_method :province, :parent
  has_many :health_centers, :class_name => "HealthCenter", :foreign_key => "parent_id"

  def count_reports_since time
    Report.joins(:place).where("reports.created_at >= ? AND places.parent_id = ?", time, id).count
  end

  def create_alerts(message, options = {})
    alerts = super
    alerts += parent.create_alerts message if Setting[:provincial_alert] != "0"
    alerts += national_and_admin_alerts(message)
    alerts
  end

  private

  def national_and_admin_alerts(body)
    roles = []
    roles << 'national' if Setting[:national_alert] != "0"
    roles << 'admin' if Setting[:admin_alert] != "0"
    return [] if roles.empty?

    User.where(:role => roles).reject{|user| user.phone_number.blank?}.map {|user| user.message(body) }
  end
end
