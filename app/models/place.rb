module Place
  def find_or_create attr
   place = self.find_by_code(attr[:code])
   if(place.nil?)
     place = self.new attr
     place.save
   end
   place
 end
end
