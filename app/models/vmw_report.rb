class VMWReport < Report
  default_scope where(:type => "VMWReport")

  def human_readable
    "We received your report of #{format_mobile} Malaria Type: #{malaria_type}, Age: #{age}, Sex: #{sex}"
  end

  def format_mobile
    mobile ? "a mobile patient with" : "a non mobile patient with"
  end

  def generate_alerts
    alerts = super
    hc_users = User.find_all_by_place_id(sender.place.parent_id)
    template_values = {
      :malaria_type => malaria_type,
      :sex => sex,
      :age => age,
      :village => place.name,
      :contact_number => sender.phone_number
    }
    hc_users.each do |user|
      alerts << { :to => user.phone_number.with_sms_protocol, :body => Setting[:village_template].apply(template_values) }
    end

    alerts
  end
end