class VMWReport < Report
  default_scope where(:type => "VMWReport")
  
  def human_readable
    "We received your report of #{format_mobile} Malaria Type: #{malaria_type}, Age: #{age}, Sex: #{sex}"
  end
  
  def format_mobile
    mobile ? "a mobile patient with" : "a non mobile patient with"
  end
end