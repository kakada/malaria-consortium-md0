class Reply < ActiveRecord::Base
  belongs_to :clinic
  has_many :replies
  belongs_to :confirm_from, :class_name => "HealthCenter"
  
  belongs_to :place
  belongs_to :od, :class_name => "OD"
  belongs_to :province, :class_name => "Province"
  belongs_to :country, :class_name => "Country"
end
