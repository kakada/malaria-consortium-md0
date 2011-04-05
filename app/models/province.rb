
class Province < ActiveRecord::Base
 has_many :district
 has_many :user , :as => :place
 validates_uniqueness_of :code
 validates_presence_of :code, :name

 extend Place
 
 

 
end