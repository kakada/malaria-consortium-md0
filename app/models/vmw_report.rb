class VMWReport < Report
  default_scope where(:type => "VMWReport")

  def human_readable
    if mobile
      Setting[:successful_mobile_village_report].apply :malaria_type => malaria_type, :age => age, :sex => sex
    else
      Setting[:successful_non_mobile_village_report].apply :malaria_type => malaria_type, :age => age, :sex => sex
    end
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
