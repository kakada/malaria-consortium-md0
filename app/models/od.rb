class OD < Place
  alias_method :province, :parent
  has_many :health_centers, :class_name => "HealthCenter", :foreign_key => "parent_id"

  def create_alerts(message, options = {})
    alerts = super
    alerts += parent.create_alerts message if Setting[:provincial_alert] != "0"
    alerts += national_and_admin_alerts(message)
    alerts
  end

  private

  def self.list
    OD.all.map{|od| "#{od.code} - #{od.name}" }
  end


  def national_and_admin_alerts(body)
    roles = []
    roles << 'national' if Setting[:national_alert] != "0"
    roles << 'admin' if Setting[:admin_alert] != "0"
    return [] if roles.empty?

    User.activated.where(:role => roles).reject{|user| user.phone_number.blank?}.map {|user| user.message(body) }
  end
end
