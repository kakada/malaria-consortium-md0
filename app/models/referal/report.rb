module Referal
  class Report < ActiveRecord::Base
    set_table_name "referal_reports"
    belongs_to :send_to_health_center, :class_name => "HealthCenter"
    belongs_to :confirm_from, :class_name => "HealthCenter"
    
    belongs_to :sender,  :class_name => "User"
    belongs_to :place
    
    belongs_to :od, :class_name => "OD"
    
    belongs_to :province, :class_name => "Province"
    belongs_to :country, :class_name => "Country"
    
    belongs_to :reply_to, :class_name => "Clinic"
    
    before_save :fill_in_data
    
    
    def fill_in_data
      self.slip_code = "#{self.od_name}#{self.book_number}#{self.code_number}"
    end
    
    # return an Array of hashes or a Hash
    def self.parse params   
      report = Referal::Report.decode(params)
      report.save!
      report.generate_alerts
    end
    
    #return Report object
    def self.decode params
      parser = Referal::Report.create_parser params
      parser.parse
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
      
      template = Referal::Report.template_from_key(key)
      
      template_values[:health_center] = self.send_to_health_center.description if send_to_health_center
      template_values[:health_center] = self.place.description if self.class == Referal::HCReport
      
      template_values[:od] = self.place.description if self.class == Referal::ClinicReport
      template_values[:od] = self.place.od.description if self.class == Referal::HCReport
      template.apply(template_values)
    end
    
    def self.template_from_key key
      template = nil
      5.times.each do |i|
         if(key == Referal::Field.columnize(i+1))
           field = Referal::Field.find_by_name(key)
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
