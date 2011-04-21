module Helpers
  def health_center code, od_id=nil
    HealthCenter.create! :name => code, :name_kh => code, :code => code, :parent_id => od_id
  end

  def village name, code = nil, health_center_id = nil
    Village.create! :name => name, :name_kh => name, :code => code, :parent_id => health_center_id
  end

  def od name
    OD.create! :name => name, :name_kh => name, :code => name
  end

  def province name
    Province.create! :name => name, :name_kh => name, :code => name
  end

  def user number, place = nil
    User.create! :phone_number => number, :place_id => place.nil? ? nil : place.id
  end

  def national_user number
    User.create! :phone_number => number, :role => "national"
  end
  
  def admin_user number
    User.create! :phone_number => number, :role => "admin"
  end
end
