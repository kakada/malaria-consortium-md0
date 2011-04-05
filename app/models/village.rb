class Village < ActiveRecord::Base
	belongs_to :district ,:health_center
end
