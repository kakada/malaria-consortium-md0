module Referral
  class Report < ActiveRecord::Base
    set_table_name "referral_reports"
    belongs_to :send_to_health_center, :class_name => "HealthCenter"
    belongs_to :confirm_from, :class_name => "User"
    
    belongs_to :sender,  :class_name => "User"
    belongs_to :place
    
    belongs_to :od, :class_name => "OD"
    
    belongs_to :province, :class_name => "Province"
    belongs_to :country, :class_name => "Country"
    
    belongs_to :reply_to, :class_name => "Clinic"
    
    before_save :fill_in_data
    
    REPORT_STATUS_CONFIRMED = 1
    
    def self.not_ignored
      where(:ignored => false )
    end
    
    def self.ignored
      where(:ignored => true )
    end
    
    def fill_in_data
      if self.slip_code.nil?
        self.slip_code = "#{self.od_name}#{self.book_number}#{self.code_number}"
      end
    end
    
    # return an Array of hashes or a Hash
    def self.process params   
      report = Referral::Report.decode(params)
      report.save(:validate => false)
      report
    end
    
    def self.health_centers
      where(["type = :type", {:type => "Referral::HCReport"}])
    end
    
    def self.clinics
      where(["type = :type", {:type => "Referral::ClinicReport"}])
    end
    
    def type
       return "Clinic" if self.class.to_s.include? "Clinic"
       return "HC"
    end
    
    #return Report object
    def self.decode params
      parser = Referral::Report.create_parser params
      report = parser.parse
      report
    end
    
    
    def parse_quality
       message_format = (self.type == "Referral::ClinicReport") ? Referral::MessageFormat.clinic : Referral::MessageFormat.health_center
       formats = message_format.format.split(Referral::MessageFormat::Separator)

       
       quality = 0 
       formats.each do |item|
         field = Referral::MessageFormat.raw_format(item)
         quality = quality+1  if !self.send(field.downcase).nil?     
       end
       return (100*quality) / formats.count
    end
    
    # return Parser object
    def self.create_parser params
      return ClinicParser.new(params) if(params[:sender].place.class == OD )
      return HCParser.new(params)  if(params[:sender].place.class == HealthCenter ) 
    end
    
    # return a String containing translated messsage
    def translate_message_for key
      template_values = {
        :phone_number => phone_number,
        :place => place.description,
        :slip_code => slip_code,
        :book_number => book_number,
        :code_number => code_number,
        :original_message => text
      }
      
      template = Referral::Report.template_from_key(key)
      
      template_values[:health_center] = self.send_to_health_center.description if send_to_health_center
      template_values[:health_center] = self.place.description if self.class == Referral::HCReport
      
      template_values[:od] = self.place.description if self.class == Referral::ClinicReport
      template_values[:od] = self.place.od.description if self.class == Referral::HCReport
      template.apply(template_values)
    end
    
    def self.template_from_key key
      template = nil
      5.times.each do |i|
         if(key == Referral::Field.columnize(i+1))
           field = Referral::Field.find_by_name(key)
           template = field.template if !field.nil?
           break
         end
      end
      # if template not found then get from the template settings
      template = Setting[key] if template.nil?
      template
    end   
    
    
    # abstract the report to raise exception
    def valid_alerts
      raise "You need to implement this method in #{self.class.to_s}" 
    end
    
    # return a Hash or an array of Hashes
    def generate_alerts
      return self.error ? error_alert : valid_alerts
    end
    
    # return a Hash
    def error_alert
      body = translate_message_for self.error_message
      self.sender.message(body)
    end
    
  end
end
