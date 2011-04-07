
class Province < ActiveRecord::Base
 has_many :districts
 has_many :users , :as => :place
 validates_uniqueness_of :code
 validates_presence_of :code, :name

 extend Place
 
 def province
   self
 end
end