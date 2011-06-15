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
    return nil if code.blank?

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
