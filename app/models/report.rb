# encoding: UTF-8
require 'csv'

class Report < ActiveRecord::Base
  default_scope where(:disabled => false)
  scope :in_falciparum_or_mimix, :conditions => {:malaria_type => ["F", "M"]}

  validates_presence_of :malaria_type, :sex, :age, :sender_id, :day, :place_id, :unless => :error?
  validates_numericality_of :age, :greater_than_or_equal_to => 0, :unless => :error?
  validates_inclusion_of :malaria_type, :in => %w(F M V N), :unless => :error?, :message => "Type should be in (F, M, V N)"
  validates_inclusion_of :sex, :in => %w(Male Female), :unless => :error?
  validates_inclusion_of :day, :in => [0, 3, 28], :unless => :error?, :message => "should be in (0, 3, 28)"

  belongs_to :sender, :class_name => "User"
  belongs_to :place
  belongs_to :village, :class_name => "Village"
  belongs_to :health_center, :class_name => "HealthCenter"
  belongs_to :od, :class_name => "OD"
  belongs_to :province, :class_name => "Province"
  belongs_to :country, :class_name => "Country"

  before_validation :upcase_strings
  before_save :complete_fields

  def self.process params
    report = self.decode params
    report.save!
    report.generate_alerts
  end
 
  
  def self.decode params
    parser = Report.create_parser params
    report = parser.parse
    report
  end
  
  def parse_quality
    formats = ["malaria_type", "age", "sex", "day"]
    quality = 0
    formats.each do |item|
      quality = quality+1  if !self.send(item).nil? 
    end
    (100*quality) / formats.count
  end
  
  def generate_alerts
    if(self.error)
      error_alert
    else
      valid_alerts
    end
  end
  
  def valid_alerts
    alerts = []
    msg = single_case_message

    # Always notify the HC about the new case (TODO: what if it's already a HC report?)
    alerts += health_center.create_alerts(msg, :except => sender)
    type = alert_triggered

    case type
    when :single
      alerts += od.create_alerts msg
    when :village
      alerts += od.create_alerts village.aggregate_report(Time.last_week)
    when :health_center
      alerts += od.create_alerts health_center.aggregate_report(Time.last_week)
    end

    # if alert message if created for od then save then specify the report is being triggered to od
    if !type.nil?
      self.trigger_to_od =  true
      save!
    end
    alerts
  end
  
  def translate_message_for key
    template_values = {
       :error_message => self.text
    }
    Setting[key].apply(template_values)
  end
    
  def error_alert
    body = translate_message_for self.error_message
    self.sender.message(body)
  end

  def self.at_place(place)
    where place.foreign_key => place.id
  end

  def self.between_dates(from, to)
    from = Time.parse(from).at_beginning_of_day
    to = Time.parse(to).at_beginning_of_day + 1.day
    where 'reports.created_at between ? and ?', from, to
  end

  def self.no_error
    where 'reports.error = ?', false
  end

  def self.not_ignored
    where 'reports.ignored = ?', false
  end

  def self.with_malaria_type(type)
    case type
    when 'Pf' then where :malaria_type => %w(F M)
    when 'Pv' then where :malaria_type => 'V'
    else where('1 = 1')
    end
  end

  def self.last_error_per_sender_per_day
    subquery = Report.select('max(reports.id)').group("date(created_at), sender_id").to_sql
    where(:error => true, :ignored => false).where("reports.id IN (#{subquery})")
  end

  def self.duplicated_per_sender_per_day
    subquery = Report.
      select('distinct reports.id').
      from('reports, reports r2').
      where('date(reports.created_at) = date(r2.created_at)').
      where('reports.sender_id = r2.sender_id').
      where('reports.text = r2.text').
      where("reports.id <> r2.id").to_sql

    where("reports.id IN (#{subquery})")
  end

  def get_full_malaria_type
    if(malaria_type == "F" || malaria_type == "M")
      return "Pf"
    end
    "Pv"
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

  def alert_triggered

    if village
      village_threshold = Threshold.find_for village
      return :village  if (village_threshold && village.reports_reached_threshold(village_threshold))
    end

    hc_threshold = Threshold.find_for health_center
    if hc_threshold
      return :health_center if health_center.reports_reached_threshold hc_threshold
    end

    if village_threshold.nil? && hc_threshold.nil?
      return :single
    end
    return nil
  end
  

  def self.report_cases options

    place = options[:place].present? ?  Place.find(options[:place]) : Country.first
    reports = Report.
                    at_place(place).between_dates(options[:from], options[:to]).
                    where("reports.#{options[:place_type].foreign_key} IS NOT NULL")

    reports = reports.no_error.not_ignored

    
    if options[:ncase] == '0'

      # select only places that reported
      reports = reports.select "DISTINCT(#{options[:place_type].foreign_key})"
      reports = reports.map {|report| report.send("#{options[:place_type].foreign_key}")}

      # Get only places that has user working on
      places = Place.joins("INNER JOIN users ON users.place_id = places.id")
      places = places.where(:type => options[:place_type])
      places = places.where("places.id NOT IN (?)", reports) if reports.size > 0
      places = places.select("DISTINCT(places.id)")

      rows = places.map { |place| place.id}
      places = Place.where("places.id IN (?)", rows ) if rows.size > 0
    else
      reports = reports.includes options[:place_type].tableize.singularize.to_sym
      reports = reports.select 'reports.*, count(*) as total'
      reports = reports.group "reports.#{options[:place_type].foreign_key}"
      reports
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
    return [] if messages.blank?

    phone_numbers = messages.map{|x| x['to'].without_protocol}
    users = User.where(:phone_number => phone_numbers).includes(:place).all
    users = Hash[users.map{|x| [x.phone_number, x]}]
    messages.each do |message|
      message['user'] = users[message['to'].without_protocol]
      message['state'] = 'sent' if ['delivered', 'confirmed'].include? message['state']
    end
    messages
  end

  def valid_reminder_case?
    not self.malaria_type.nil? and (self.malaria_type.upcase == "F" or self.malaria_type.upcase == "M") and self.error_message.nil?
  end
  
  private

  def complete_fields
    self.malaria_type = self.malaria_type.nil? ? nil : self.malaria_type.upcase
    self.health_center = !village_id.nil? ? village.parent : (place.class.to_s == "HealthCenter" ? place: nil)
    self.od = health_center.parent if health_center_id?
    self.province = od.parent if od_id?
    self.country = province.parent if province_id?
  end
  
  
  
  def self.create_parser params
    return VMWReportParser.new(params) if(params[:sender].place.class.to_s == "Village")
    return HCReportParser.new(params)  if(params[:sender].place.class.to_s == "HealthCenter") 
  end
  
  def self.create_error_report(message, error_message, sender = nil)
    options = { :sender_address => message[:from], 
                :text => message[:body],
                :nuntium_token => message[:guid],
                :error => true,
                :error_message => error_message,
                :sender => sender,
                :place => sender.try(:place) }
    Report.create! options
  end

  def upcase_strings
    malaria_type.upcase! if malaria_type
  end
end
