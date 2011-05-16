class VMWReport < Report
  default_scope where(:type => "VMWReport")

  def human_readable
    "We received your report of #{format_mobile} Malaria Type: #{malaria_type}, Age: #{age}, Sex: #{sex}"
  end

  def format_mobile
    mobile ? "a mobile patient with" : "a non mobile patient with"
  end

  def single_case_message
    template_values = {
      :malaria_type => malaria_type,
      :sex => sex,
      :age => age,
      :village => village.name,
      :contact_number => sender.phone_number
    }
    Setting[:single_village_case_template].apply(template_values)
  end

end