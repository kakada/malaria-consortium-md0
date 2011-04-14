class Place < ActiveRecord::Base
  has_many :users
  has_many :sub_places, :class_name => "Place", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Place"

  validates_uniqueness_of :code

  Country = "Country"
  Province = "Province"
  OD = "OD"
  HealthCenter = "HealthCenter"
  Village = "Village"

  Place.constants(false).each do |constant|
    # Define classes for each of the previous constants, so instead of
    #
    #   Place.find_by_place_type_and_name Place::Country, "foo"
    #
    # we can do
    #
    #   Country.find_by_name "foo"
    class_eval %Q(
      class ::#{constant} < Place
        default_scope where(:place_type => Place::#{constant})
      end
    )

    # Define has_many :provinces, etc., that will restrict the sub_places to the correct places types
    has_many constant.to_s.tableize.to_sym, :class_name => "Place", :foreign_key => "parent_id", :conditions => {:place_type => constant.to_s}
  end

  def health_center
    case place_type
    when Place::Village
      parent
    when Place::HealthCenter
      self
    else
      nil
    end
  end

  def od
    case place_type
    when Place::Village
      health_center.od
    when Place::HealthCenter
      parent
    when Place::OD
      self
    else
      nil
    end
  end

  def province
    case place_type
    when Place::Village, Place::HealthCenter
      od.province
    when Place::OD
      parent
    when Place::Province
      self
    else
      nil
    end
  end
end

