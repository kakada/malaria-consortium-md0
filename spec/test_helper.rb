def health_center code, od_id=nil
  Place.create!(:name => code, :name_kh => code, :code => code, :parent_id => od_id, :place_type => Place::HealthCenter)
end

def village name, code, health_center_id = nil
  Place.create!(:name => name, :name_kh => name, :code => code, :parent_id => health_center_id,
                :place_type => Place::Village)
end

def user number, place
  User.create!(:phone_number => number, :place_id => place.id)
end

def national_user number
  User.create!(:phone_number => number, :role => "national")
end