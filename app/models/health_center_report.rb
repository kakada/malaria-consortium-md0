class HealthCenterReport < Report
  default_scope where(:type => "HealthCenterReport")
  
  def human_readable
    "We received your report of Malaria Type: #{malaria_type}, Age: #{age}, Sex: #{sex}, Village: #{village.code}"
  end
end