class HealthCenter < ActiveRecord::Base
	has_many :village
	belongs_to :district
end
