class VillageAlert < Alert
  default_scope where(:source_type => "Village")
end