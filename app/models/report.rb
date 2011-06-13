# encoding: UTF-8
require 'csv'
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
  belongs_to :country, :class_name => "Country"

  before_validation :upcase_strings
  before_save :complete_fields
  after_create :copy_self_to_sender, :if => :sender_id?
  after_update :remove_self_from_sender, :if => :sender_id?

  def self.process(message = {})
    message = message.with_indifferent_access
    error, messages = decode message

    if messages.nil?
      [{ :from => from_app, :to => message[:from], :body => error }]
    else
      messages.map { |msg| msg.merge :from => from_app }
    end
  end

  def self.at_place(place)
    where place.foreign_key => place.id
  end

  def self.between_dates(from, to)
    where 'reports.created_at between ? and ?', from, to
  end

  def self.no_error
    where 'reports.error = 0 '
  end

  def self.with_malaria_type(type)
    case type
    when 'Pf' then where :malaria_type => %w(F M)
    when 'Pv' then where :malaria_type => 'V'
    else where('1 = 1')
    end
  end

  def self.unknown_user(original_message = nil)
    "You are not registered in Maladira Day 0."
  end

  def self.user_should_belong_to_hc_or_village(original_message = nil)
    "Access denied. You should either belong to a health center or be Village Malaria Worker."
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

  def self.report_cases options
    place = options[:place].present? ?  Place.find(options[:place]) : Country.first
    reports = Report.at_place(place).between_dates(options[:from], options[:to]).where("reports.#{options[:place_type].foreign_key} IS NOT NULL")
    reports = reports.where(:error => false)
    if options[:ncase] == '0'
      reports = reports.select "DISTINCT(#{options[:place_type].foreign_key})"
      ids = reports.map &:"#{options[:place_type].foreign_key}"

      places = Place.where("id NOT IN (?)", ids).where(:type => options[:place_type])
      #places = places.paginate :page => options[:page], :per_page => 25, :order => "name"
    else
      reports = reports.includes options[:place_type].tableize.singularize.to_sym
      reports = reports.select 'reports.*, count(*) as total'
      reports = reports.group "reports.#{options[:place_type].foreign_key}"
      #reports = reports.paginate :page => options[:page], :per_page => 25, :order => "total desc"
    end
  end

  def self.report_cases_all options
    reports = Report.report_cases options
    if(options[:ncase] == "0")
      reports = reports.order " name desc "
    else
      reports = reports.order " total desc "
    end

  end

  def self.report_file(place_type,from, to)
    "Report #{place_type} #{from}, #{to}.csv"
  end
  def self.write_csv options
    reports = Report.report_cases_all options
    file = "#{Rails.root}/tmp/Report #{self.report_file(options[:place_type], options[:from], options[:to])}.csv"

    CSV.open(file,"wb") do |csv|
      csv << [options[:place_type],"Code","Total", "Health Center", "OD", "Province"]
      reports.each do |report|
        if options[:ncase] == '0'
          place = report
          csv << [place.name, place.code, 0, place.health_center.name_with_code, place.od.name_with_code, place.province.name_with_code]
        else
          place = options[:place_type] == 'Village' ? report.village : report.health_center
          csv << [place.name, place.code, report.total, place.health_center.name_with_code, place.od.name_with_code, place.province.name_with_code]
        end
      end
    end
    file
  end

  def self.report_cases_paginate options
    reports =  self.report_cases options

    if options[:ncase] == '0'
      reports.paginate :page => options[:page], :per_page => 20, :order =>"code asc"
    else
      reports.paginate :page => options[:page], :per_page => 20, :order =>"total desc"
    end
  end

  def generated_messages
    messages = Nuntium.new_from_config.get_ao nuntium_token
    phone_numbers = messages.map{|x| x['to'].without_protocol}
    users = User.where(:phone_number => phone_numbers).includes(:place).all
    users = Hash[users.map{|x| [x.phone_number, x]}]
    messages.each do |message|
      message['user'] = users[message['to'].without_protocol]
      message['state'] = 'pending' if message['state'] == 'queued'
    end
    messages
  end

  private

  def complete_fields
    self.health_center = village_id? ? village.parent : place
    self.od = health_center.parent if health_center_id?
    self.province = od.parent if od_id?
    self.country = province.parent if province_id?
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
    report.nuntium_token = message[:guid]
    report.save!

    return parser.error if parser.errors?

    alerts = report.generate_alerts
    reply = {:to => sender.phone_number.with_sms_protocol, :body => report.human_readable}

    [nil, alerts.push(reply)]
  end

  def self.create_error_report(message, error_message, sender = nil)
    Report.create! :sender_address => message[:from], :text => message[:body], :nuntium_token => message[:guid], :error => true, :error_message => error_message, :sender => sender, :place => sender.try(:place)
  end

  def upcase_strings
    malaria_type.upcase! if malaria_type
  end

  def copy_self_to_sender
    sender.last_report = self
    sender.last_report_error = self.error?
    sender.save!
  end

  def remove_self_from_sender
    if sender.last_report_id == self.id
      sender.last_report_error = self.error?
      sender.save!
    end
  end
end
