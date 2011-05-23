class Place < ActiveRecord::Base
  has_many :users
  has_many :sub_places, :class_name => "Place", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Place"
  
  validates_uniqueness_of :code



  Types = ["Country", "Province", "OD", "HealthCenter", "Village"]

  Types.each do |constant|
    # Define classes for each place
    class_eval %Q(
      class ::#{constant} < Place
        default_scope where(:type => "#{constant}")
      end
    )

    # Define has_many :provinces, etc., that will restrict the sub_places to the correct places types
    has_many constant.tableize.to_sym, :class_name => constant, :foreign_key => "parent_id"

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

end

class Country
end

class Province
  alias_method :country, :parent
end

class OD
  alias_method :province, :parent

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
end

class HealthCenter
  alias_method :od, :parent
  delegate :province, :to => :od

  def report_parser(user)
    HCReportParser.new user
  end
end

