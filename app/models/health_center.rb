class HealthCenter < ActiveRecord::Base
	has_many :villages
  has_many :users ,:as => :place
	belongs_to :district

  extend Place
end
