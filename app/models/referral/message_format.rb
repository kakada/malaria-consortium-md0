module Referral
  class MessageFormat < ActiveRecord::Base
    set_table_name "referral_message_formats"
    Separator = "."
    Mobile = "."
    
    TYPE_HC = "referral_health_center"
    TYPE_CLINIC = "referral_clinic"
    
    
    def self.raw_format str
      format = str.strip
      format[1, format.size-2]
    end
    
    def self.wrap_format str
      "{#{str}}"
    end
    
    def self.health_center
       Referral::MessageFormat.find_or_create_by_sector self::TYPE_HC
    end
    
    def self.clinic
      Referral::MessageFormat.find_or_create_by_sector self::TYPE_CLINIC
    end
  end
end