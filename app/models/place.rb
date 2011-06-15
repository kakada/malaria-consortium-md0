class Place < ActiveRecord::Base
  has_many :users
  has_many :reports
  has_many :sub_places, :class_name => "Place", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Place"
  before_save :unset_hierarchy
  after_save :set_hierarchy

  validates_presence_of :name
  validates_presence_of :code, :unless => :country?
  validates_uniqueness_of :code

  before_validation :set_parent_from_intended_parent_code, :if => lambda { @intended_parent_code }
  validate :intended_parent_code_must_exist, :if => lambda { @intended_parent_code && !parent }

  def self.find_by_code(code)
    pieces = code.strip.split(/\s/, 2)
    if pieces.length == 2
      Place.where(:code => pieces.first).first
    else
      Place.where(:code => code).first
    end
  end

  def self.foreign_key
    self.to_s.foreign_key
  end

  def foreign_key
    self.class.foreign_key
  end

  def self.sub_place_class
    Types[1 + Types.index(to_s)] || Types.last
  end

  def sub_place_class
    self.class.sub_place_class
  end

  def self.parent_class
    Types[Types.index(to_s) - 1] || Types.first
  end

  def parent_class
    self.class.parent_class
  end

  def unset_hierarchy
    self.hierarchy = nil unless changes.except(:hierarchy).empty?
  end

  def name_with_code
    "#{self.code} #{self.name}"
  end

  def intended_parent_code
    parent.try(:description)
  end

  def intended_parent_code=(code)
    @intended_parent_code = code
  end

  def set_hierarchy
    if self.hierarchy.nil?
      self.hierarchy = (self.parent_id ? "#{self.parent.hierarchy}." : '') + self.id.to_s
      update :hierarchy => self.hierarchy
    end
  end

  # The hierarchy of place types, ordered by top to bottom
  Types = ["Country", "Province", "OD", "HealthCenter", "Village"]

  Types.each do |constant|
    # Define classes for each place
    class_eval "class ::#{constant} < Place; end"

    # Define generic methods to get the village, country, etc., of a place.
    # This base class just returns self if the type is the name of the method, otherwise nil.
    class_eval %Q(
      def #{constant.tableize.singularize}
        type == "#{constant}" ? self : nil
      end
    )

    # Define question methods to ask if a place is of a given place type, i.e.: place.village?
    class_eval %Q(
      def #{constant.tableize.singularize}?
        type == "#{constant}"
      end
    )
  end

  # Returns a report parser for this place type and user
  def report_parser(user)
    nil
  end

  def description
    "#{code} #{name} (#{self.class.name.titleize})"
  end

  def short_description
    "#{code} #{name}"
  end

  def self.places_by_type(type = nil)
    if(type.nil? || type =="")
      Place.all
    else
      Place.where("type=?",type)
    end
  end

  def self.search_for_autocomplete(query)
    where "code LIKE :q OR name LIKE :q", :q => "#{query.strip}%"
  end

  def count_sent_reports_since time
    Report.where("created_at >= ? AND place_id = ?", time, id).count
  end

  def get_parent type
    p = self
    while p != nil && p.class != type
      p = p.parent
    end
    p
  end

  def create_alerts body, options = {}
    users.reject{|user| user == options[:except]}.map{|user| user.message(body) }
  end

  #update province that doesnt belong to country
  def self.update_country
    country = Country.national

    Province.all.each do |province|
      province.parent = country
      province.save!
    end
  end

  def reports
    Report.where self.foreign_key => self.id
  end

  def name
    attributes['name'] || ''
  end

  private

  def set_parent_from_intended_parent_code
    self.parent = Place.find_by_code @intended_parent_code
  end

  def intended_parent_code_must_exist
    errors.add(:intended_parent_code, "doesn't exist")
  end

end

class Country
  def self.national
    first || create_national!
  end

  def self.create_national!
    Country.create! :name => 'National', :code => '', :lat => 12.71536762877211, :lng => 104.8974609375
  end
end

class Province
  alias_method :country, :parent
  has_many :ods, :class_name => "OD", :foreign_key => "parent_id"
  before_save :assign_national_country, :unless => :parent_id?

  private

  def assign_national_country
    self.parent = Country.national
  end
end

class OD
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

class Village
  alias_method :health_center, :parent
  delegate :od, :to => :health_center
  delegate :province, :to => :od

  def report_parser(user)
    VMWReportParser.new user
  end

  def reports_since time
    Report.where("created_at >= ? AND village_id = ?", time, id)
  end

  def count_reports_since time
    reports_since(time).count
  end

  def aggregate_report time
    counts = reports_since(time).group(:malaria_type).count
    template_values = {
      :cases => counts.values.sum,
      :f_cases => counts['F'] || 0,
      :v_cases => counts['V'] || 0,
      :m_cases => counts['M'] || 0,
      :village => self.name
    }
    Setting[:aggregate_village_cases_template].apply(template_values)
  end
end

class HealthCenter
  alias_method :od, :parent
  delegate :province, :to => :od
  has_many :villages, :class_name => "Village", :foreign_key => "parent_id"

  def report_parser(user)
    HCReportParser.new user
  end

  def reports_since time
    Report.where(:village_id => Village.where(:parent_id => id)).where("created_at >= ?", time)
  end

  def count_reports_since time
    reports_since(time).count
  end

  def aggregate_report time
    counts = reports_since(time).group(:malaria_type).count
    template_values = {
      :cases => counts.values.sum,
      :f_cases => counts['F'] || 0,
      :v_cases => counts['V'] || 0,
      :m_cases => counts['M'] || 0,
      :health_center => self.name
    }
    Setting[:aggregate_hc_cases_template].apply(template_values)
  end
end

