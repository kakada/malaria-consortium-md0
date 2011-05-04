class HealthCenterAlert < Alert
  default_scope where(:source_type => "HealthCenter")
end