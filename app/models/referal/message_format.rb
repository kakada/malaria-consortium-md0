module Referal
  class MessageFormat < ActiveRecord::Base
    set_table_name "referal_message_formats"
    Separator = "."
    Mobile = "."
    
    TYPE_HC = "referal_health_center"
    TYPE_CLINIC = "referal_clinic"
    
    
    def self.raw_format str
      format = str.strip
      format[1, format.size-2]
    end
    
    def self.wrap_format str
      "{#{str}}"
    end
    
    def self.health_center
       Referal::MessageFormat.find_or_create_by_sector self::TYPE_HC
    end
    
    def self.clinic
      Referal::MessageFormat.find_or_create_by_sector self::TYPE_CLINIC
    end
  end
end