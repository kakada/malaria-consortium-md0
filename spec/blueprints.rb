require 'machinist/active_record'

Sham.define do
  name { Faker::Name.name }
  number8 { (1..8).map { ('1'..'9').to_a.rand }.join }
end

Place.blueprint do
  name
  code { Sham.number8.to_s }
end

Country.blueprint do
end

Province.blueprint do
end

OD.blueprint do
  parent { Province.make }
end

HealthCenter.blueprint do
  parent { OD.make }
end

Village.blueprint do
  parent { HealthCenter.make }
end

User.blueprint do
  phone_number { Sham.number8 }
end

User.blueprint :admin do
  role { 'admin' }
end

User.blueprint :national do
  role { 'national' }
end

User.blueprint :in_province do
  place { Province.make }
end

User.blueprint :in_od do
  place { OD.make }
end

User.blueprint :in_village do
  place { Village.make }
end

User.blueprint :in_health_center do
  place { HealthCenter.make }
end

Report.blueprint do
  malaria_type { ['F', 'M', 'V'].sample }
  sex { ['Female', 'Male'].sample }
  age { rand(50) }
  sender
  place { [Village, HealthCenter].sample.make }
  village
end

VMWReport.blueprint do
  sender { User.make :place => Village.make }
  place { sender.place }
  village { sender.place }
end

HealthCenterReport.blueprint do
  sender { User.make :place => HealthCenter.make }
  place { sender.place }
  village { Village.make :parent => sender.place }
end

AlertPf.blueprint do
  
end
