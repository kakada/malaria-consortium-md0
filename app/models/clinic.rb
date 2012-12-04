# encoding: UTF-8

class Clinic < ActiveRecord::Base
  
  has_many :replies
  belongs_to :confirm_from, :class_name => "HealthCenter"
  
  belongs_to :sender,  :class_name => "User"
  belongs_to :place
  belongs_to :od, :class_name => "OD"
  belongs_to :province, :class_name => "Province"
  belongs_to :country, :class_name => "Country"
end

