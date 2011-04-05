class District < ActiveRecord::Base
	has_many :village
	belongs_to :province
end
