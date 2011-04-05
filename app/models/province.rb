class Province < ActiveRecord::Base
 has_many :district
 has_many :user , :as => :place
end