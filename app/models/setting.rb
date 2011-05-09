class Setting < ActiveRecord::Base

  def self.[](key)
    setting = Setting.find_by_param(key)
    return "0" unless setting
    setting.value.to_s
  end

  def self.[]=(key, value)
    setting = Setting.find_by_param(key) || Setting.new(:param => key)
    setting.value = value
    setting.save!
    setting[key]
  end

end
