class Templates
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  Keys = %w(single_village_case_template single_hc_case_template aggregate_village_cases_template aggregate_hc_cases_template)

  ValidParameters = {
    :single_village_case_template => %w(malaria_type sex age village contact_number),
    :single_hc_case_template => %w(malaria_type sex age village contact_number health_center),
    :aggregate_village_cases_template => %w(cases f_cases v_cases m_cases village),
    :aggregate_hc_cases_template => %w(cases f_cases v_cases m_cases health_center),
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

  Keys.each do |key|
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
          self.errors.add(:#{key}, "Incorrect parameter: {" + param[0] + "}") unless ValidParameters[:#{key}].include? param[0]
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
