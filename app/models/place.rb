class Place < ActiveRecord::Base
  has_many :users
  has_many :sub_places, :class_name => "Place", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Place"
  
  validates_uniqueness_of :code
  
  Place::Country = "Country"
  Place::Province = "Province"
  Place::OD = "OD"
  Place::HealthCenter = "HealthCenter"
  Place::Village = "Village"
  
  def self.find_or_create attr
     place = self.find_by_code(attr[:code])
     if place.nil?
       place = self.new attr
       place.save
     end
     place
  end
  
  def self.provinces 
    Place.find_all_by_place_type Province
  end
  
  def self.ods
    Place.find_all_by_place_type OD
  end
  
  def self.health_centers
    Place.find_all_by_place_type HealthCenter
  end
  
  def self.villages
    Place.find_all_by_place_type Village
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
