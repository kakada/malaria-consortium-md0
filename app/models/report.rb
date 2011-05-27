class Report < ActiveRecord::Base
  validates_presence_of :malaria_type, :sex, :age, :sender_id, :place_id, :village_id, :unless => :error?
  validates_numericality_of :age, :greater_than_or_equal_to => 0, :unless => :error?
  validates_inclusion_of :malaria_type, :in => %w(F M V), :unless => :error?
  validates_inclusion_of :sex, :in => %w(Male Female), :unless => :error?

  belongs_to :sender, :class_name => "User"
  belongs_to :place
  belongs_to :village, :class_name => "Village"
  belongs_to :health_center, :class_name => "HealthCenter"
  belongs_to :od, :class_name => "OD"
  belongs_to :province, :class_name => "Province"

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

  def self.unknown_user(original_message = nil)
    "You are not registered in Maladira Day 0."
  end

  def self.user_should_belong_to_hc_or_village(original_message = nil)
    "Access denied. You should either belong to a health center or be Village Malaria Worker."
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
    sender = User.find_by_phone_number sender_number
    users = users.concat(sender.od.province.users) if Setting[:provincial_alert] != "0"

    users = users.concat User.find_all_by_role("admin") if Setting[:admin_alert] != "0"
    users = users.concat User.find_all_by_role "national" if Setting[:national_alert] != "0"

    alerts = []
    users.each do |user|
      alerts.push :to => user.phone_number.with_sms_protocol, :body => message
    end
    alerts
  end

  private

  def complete_fields
    self.health_center = village_id? ? village.health_center : place
    self.od = health_center.od if health_center_id?
    self.province = od.province if od_id?
  end

  def self.decode message
    sender = User.find_by_phone_number message[:from]
    if sender.nil?
      create_error_report message, 'unknown user'
      return unknown_user
    end

    if !sender.can_report?
      create_error_report message, 'access denied', sender
      return user_should_belong_to_hc_or_village
    end

    parser = sender.report_parser
    parser.parse message[:body]

    report = parser.report
    report.save!

    return parser.error if parser.errors?

    alerts = report.generate_alerts
    reply = {:to => sender.phone_number.with_sms_protocol, :body => report.human_readable}

    [nil, alerts.push(reply)]
  end

  def self.create_error_report(message, error_message, sender = nil)
    Report.create! :sender_address => message[:from], :text => message[:body], :error => true, :error_message => error_message, :sender => sender, :place => sender.try(:place)
  end

  def upcase_strings
    malaria_type.upcase! if malaria_type
  end
end
