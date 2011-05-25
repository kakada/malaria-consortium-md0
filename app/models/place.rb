class Place < ActiveRecord::Base
  has_many :users
  has_many :sub_places, :class_name => "Place", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Place"
  before_save :unset_hierarchy
  after_save :set_hierarchy
  
  validates_uniqueness_of :code

  def unset_hierarchy
    self.hierarchy = nil unless changes.except(:hierarchy).empty?
  end

  def set_hierarchy
    if self.hierarchy.nil?
      self.hierarchy = (self.parent_id ? "#{self.parent.hierarchy}." : '') + self.id.to_s
      update hierarchy: self.hierarchy
    end
  end

  Types = ["Country", "Province", "OD", "HealthCenter", "Village"]

  Types.each do |constant|
    # Define classes for each place
    class_eval %Q(
      class ::#{constant} < Place
        default_scope where(:type => "#{constant}")
      end
    )

    # Define has_many :provinces, etc., that will restrict the sub_places to the correct places types
    #has_many constant.tableize.to_sym, :class_name => constant, :foreign_key => "parent_id"

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
    "#{name} (#{self.class.name.titleize}, #{code})"
  end

  def self.levels
    Types[1..-1]
  end

  def self.places_by_type(type = nil)
    if(type.nil? || type =="")
      Place.all
    else
      Place.where("type=?",type)
    end
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

  def create_alerts message, options = {}
    alerts = []
    except = options[:except]
    users.each do |user|
      alerts << {:to => user.phone_number.with_sms_protocol, :body => message} unless user == except
    end
    alerts
  end

end

class Country
  
end

class Province
  alias_method :country, :parent
  has_many :ods, :class_name => "OD", :foreign_key => "parent_id"
end

class OD
  alias_method :province, :parent
  has_many :health_centers, :class_name => "HealthCenter", :foreign_key => "parent_id"

  def count_reports_since time
    Report.joins(:place).where("reports.created_at >= ? AND places.parent_id = ?", time, id).count
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

