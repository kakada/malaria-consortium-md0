class Threshold < ActiveRecord::Base
  belongs_to :place
  before_save :set_place_hierarchy

  def set_place_hierarchy
    self.place_hierarchy = self.place.hierarchy
  end

  def self.find_for place
    place_class = place.class.name
    threshold = nil
    while place && threshold.nil?
      threshold = Threshold.where(:place_class => place_class, :place_id => place.id).first
      place = place.parent
    end
    threshold
  end
end