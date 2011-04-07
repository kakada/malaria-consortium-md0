class Village < ActiveRecord::Base
	belongs_to :district
  belongs_to :health_center
  has_many :users, :as => :place

  validates_uniqueness_of :code

  extend Place

  def province
    district.province
  end
end
