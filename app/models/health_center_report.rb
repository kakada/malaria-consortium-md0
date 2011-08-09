class HealthCenterReport < Report
  default_scope where(:type => "HealthCenterReport")

  def human_readable
    Setting[:successful_health_center_report].apply :test_result => get_full_malaria_type, :malaria_type => malaria_type, :age => age, :sex => sex, :village_code => village.code
  end

  def single_case_message
    template_values = {
      :test_result => get_full_malaria_type,
      :malaria_type => malaria_type,
      :sex => sex,
      :age => age,
      :village => village.name,
      :contact_number => sender.phone_number,
      :health_center => sender.place.name
    }
    Setting[:single_hc_case_template].apply(template_values)
  end
end
