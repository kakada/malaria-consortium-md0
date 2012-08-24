class Templates
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  Keys = {
    :single_village_case_template => {:params => %w(test_result malaria_type sex age day village contact_number), :label => 'individual case report from a village malaria worker'},
    :single_hc_case_template => {:params => %w(test_result malaria_type sex age day village contact_number health_center), :label => 'individual case report from a health center'},
    :aggregate_village_cases_template => {:params => %w(cases pv_cases pf_cases f_cases v_cases m_cases village), :label => 'aggregated cases report at village level'},
    :aggregate_hc_cases_template => {:params => %w(cases pv_cases pf_cases f_cases v_cases m_cases health_center), :label => 'aggregated cases report at health center level'},
    :successful_health_center_report => {:params => %w(test_result malaria_type age sex day village_code), :label => 'successful health center report message'},
    :successful_mobile_village_report => {:params => %w(test_result malaria_type age sex day mobile), :label => 'successful mobile village report message'},
    :successful_non_mobile_village_report => {:params => %w(test_result malaria_type age sex day mobile), :label => 'successful non mobile village report message'},
    :invalid_malaria_type => {:params => %w(original_message), :label => 'invalid malaria type message'},
    :invalid_age => {:params => %w(original_message), :label => 'invalid age message'},
    :invalid_sex => {:params => %w(original_message), :label => 'invalid sex message'},
    :invalid_day => {:params => %w(original_message), :label => 'invalid day message'},
    :invalid_village_code => {:params => %w(original_message), :label => 'invalid village code'},
    :non_existent_village => {:params => %w(original_message), :label => 'non existing village'},
    :too_long_village_report => {:params => %w(original_message), :label => 'invalid mobile patient'},
    :reminder_message_vmw => {:params => %w(original_message phone_number village health_center), :label => "reminder message to VMW"},
    :reminder_message_hc => {:params => %w(original_message phone_number village health_center), :label => "reminder message to HC, OD, PHD, National and Admin"}
  }

  def initialize(values = {})
    @settings = Setting.all
    values.each { |key, value| send "#{key}=", value }
  end

  def setting_for_key(param)
    setting = @settings.select{|x| x.param == param}.first
    if !setting
      setting = Setting.new(:param => param)
      @settings << setting
    end
    setting
  end
  
  def self.get_reminder_template_message user
    (!user.place.nil? and user.place.type == Village.name)? Setting[:reminder_message_vmw] : Setting[:reminder_message_hc]
  end

  Keys.each do |key, value|
    class_eval %Q(
      validate :validate_#{key}

      def #{key}
        setting_for_key('#{key}').value
      end

      def #{key}=(value)
        setting_for_key('#{key}').value = value
      end

      def validate_#{key}
        (#{key} || '').scan /\{([^\}]*)\}/ do |param|
          self.errors.add(:#{key}, "Incorrect parameter: {" + param[0] + "}") unless Keys[:#{key}][:params].include? param[0]
        end
      end
    )
  end
  
  def save
    return false unless valid?

    @settings.select{|x| x.changes.present? && !x.value.nil?}.each &:save!
    true
  end

end
