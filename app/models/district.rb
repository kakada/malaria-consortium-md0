class District < ActiveRecord::Base
	has_many :village
  has_many :user, :as => :place
	belongs_to :province
end
