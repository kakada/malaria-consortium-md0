require 'machinist/active_record'

Sham.define do
  name { Faker::Name.name }
  number8 { (1..8).map { ('1'..'9').to_a.rand }.join }
end

Place.blueprint do
  name
  code { Sham.number8.to_s }
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
