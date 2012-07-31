class AlertPf < ActiveRecord::Base
  serialize :provinces

  def self.has_province? province
	AlertPf.last.provinces.include?(province)
  end
end
