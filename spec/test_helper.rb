def health_center code, od_id=nil
  Place.create!(:name => code, :name_kh => code, :code => code, :parent_id => od_id, :place_type => Place::HealthCenter)
end

def village name, code = nil, health_center_id = nil
  Place.create!(:name => name, :name_kh => name, :code => code, :parent_id => health_center_id,
                :place_type => Place::Village)
end

def od name
  Place.create!(:name => name, :name_kh => name, :code => name, :place_type => Place::OD)
end

def province name
  Place.create!(:name => name, :name_kh => name, :code => name, :place_type => Place::Province)
end

def user number, place = nil
  User.create!(:phone_number => number, :place_id => place.nil? ? nil : place.id)
end

def national_user number
  User.create!(:phone_number => number, :role => "national")
end