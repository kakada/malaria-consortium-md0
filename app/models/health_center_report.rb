class HealthCenterReport < Report
  default_scope where(:type => "HealthCenterReport")

  def human_readable
    "We received your report of Malaria Type: #{malaria_type}, Age: #{age}, Sex: #{sex}, Village: #{village.code}"
  end

  def single_case_message
    template_values = {
      :malaria_type => malaria_type,
      :sex => sex,
      :age => age,
      :village => village.name,
      :contact_number => sender.phone_number,
      :health_center => sender.place.name
    }
    single_case_msg = Setting[:single_hc_case_template].apply(template_values)
  end
end
