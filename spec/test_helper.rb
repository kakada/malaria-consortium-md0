def health_center code, district_id=nil
  HealthCenter.create!(:name => code, :name_kh => code, :code => code, :district_id => district_id)
end

def village name, code, health_center_id = nil
  Village.create!(:name => name,
                                :name_kh => name,
                                :code => code,
                                :health_center_id => health_center_id)
end

def user number, place
  User.create!(:phone_number => number,
                          :place_id => place.id,
                          :place_type => place.class.to_s)
end

def national_user number
  User.create!(:phone_number => number, :role => "national")
end