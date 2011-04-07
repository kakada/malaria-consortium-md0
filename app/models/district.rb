class District < ActiveRecord::Base
	has_many :villages
  has_many :users, :as => :place
	belongs_to :province

  extend Place

  def district
    self
  end
end
