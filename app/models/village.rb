class Village < ActiveRecord::Base
	belongs_to :district ,:health_center 
  has_many :user, :as => :place

end
