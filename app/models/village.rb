class Village < ActiveRecord::Base
	belongs_to :district
  belongs_to :health_center
  has_many :user, :as => :place

  extend Place

end
