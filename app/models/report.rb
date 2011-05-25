class Report < ActiveRecord::Base
  validates_presence_of :malaria_type, :sex, :age, :sender_id, :place_id
  validates_inclusion_of :malaria_type, :in => %w(F M V)
  validates_inclusion_of :sex, :in => %w(Male Female)

  belongs_to :sender, :class_name => "User"
  belongs_to :place
  belongs_to :village, :class_name => "Village"

  before_validation :upcase_strings
  before_save :complete_fields

  def self.process(message = {})
    message = message.with_indifferent_access
    error, messages = decode message

    if messages.nil?
      [{ :from => from_app, :to => message[:from], :body => error }]
    else
      messages.map { |msg| msg.merge :from => from_app }
    end
  end

  def self.unknown_user original_message
    "User unknown."
  end

  def self.user_should_belong_to_hc_or_village
    "Access denied. User should either belong to a health center or be Village Malaria Worker."
  end

  def self.too_long_vmw_report original_message
    "The report you sent is too long. Your report was #{original_message}. Please correct and send again."
  end

  def self.from_app
    "malariad0://system"
  end

  def generate_alerts
    alerts = []

    msg = single_case_message

    # Always notify the HC about the new case (TODO: what if it's already a HC report?)
    alerts += village.parent.create_alerts(msg, :except => sender)

    case alert_triggered
    when :single
      alerts += village.get_parent(OD).create_alerts(msg)
    when :village
      alerts += village.get_parent(OD).create_alerts(village.aggregate_report 7.days.ago)
    when :health_center
      alerts += village.get_parent(OD).create_alerts(village.parent.aggregate_report 7.days.ago)
    end

    alerts
  end

  def alert_triggered
    hc_threshold = Threshold.find_for village.parent
    if hc_threshold
      return :health_center if village.parent.count_reports_since(7.days.ago) >= hc_threshold.value
    end

    village_threshold = Threshold.find_for village
    if village_threshold
      return :village if village.count_reports_since(7.days.ago) >= village_threshold.value
    elsif hc_threshold.nil?
      return :single
    end

    return nil
  end


  def self.alert_upper_level sender_number, message
    users = []
    sender = Report.sender_sms(sender_number)
    users = users.concat(sender.od.province.users) if Setting[:provincial_alert] != "0"

    users = users.concat User.find_all_by_role("admin") if Setting[:admin_alert] != "0"
    users = users.concat User.find_all_by_role "national" if Setting[:national_alert] != "0"

    alerts = []
    users.each do |user|
      alerts.push :to => user.phone_number.with_sms_protocol, :body => message
    end
    alerts
 end

 def complete_fields
   village =  Place.find(self.village_id)
   self.health_center_id = village.health_center.id
   self.od_id = village.od.id
   self.province_id = village.province.id
  end



  private
  def self.sender_sms from
    User.find_by_phone_number from
  end

  def self.decode message
    sender = Report.sender_sms message[:from].without_protocol.strip
    return unknown_user(message[:body]) if sender.nil?

    return user_should_belong_to_hc_or_village if not sender.can_report?

    parser = sender.report_parser
    parser.parse message[:body]

    return parser.error if parser.errors?

    report = parser.report
    report.save!

    alerts = report.generate_alerts
    reply = {:to => sender.phone_number.with_sms_protocol, :body => report.human_readable}

    [nil, alerts.push(reply)]
  end

  def upcase_strings
    malaria_type.upcase!
  end
end