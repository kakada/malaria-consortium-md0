# encoding: UTF-8
require "csv"

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
    
    REPORT_STATUS = [["Not confirmed", 0], ["Confirmed", 1]]
    REPORT_IGNORED = [["Not ignored", 0], ["Ignored", 1]]
    
    def self.not_ignored
      where(:ignored => false )
    end
    
    def self.ignored
      where(:ignored => true )
    end
    
    def self.error
      where(:error => true)
    end
    
    def self.no_error
      where(:error => false)
    end
    
    def self.query term
      where(["text LIKE :q ", {:q => "%#{term.strip()}%"}])
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
      return ClinicParser.new(params) if(params[:sender].place.class == Village )
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
      
      template_values[:health_center] = self.send_to_health_center.intended_place_code if send_to_health_center
      template_values[:health_center] = self.place.intended_place_code if self.class == Referral::HCReport
      
      template_values[:od] = self.place.intended_place_code if self.class == Referral::ClinicReport
      template_values[:od] = self.place.od.intended_place_code if self.class == Referral::HCReport
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
    
    def self.duplicated_per_sender
      subquery = Report.
        select('distinct r1.id').
        from('referral_reports r1, referral_reports r2').
        where('r1.sender_id = r2.sender_id').
        where('r1.text = r2.text').
        where("r1.id <> r2.id").
        where("r1.ignored != 1 AND r2.ignored !=1").
        order("r1.id DESC").to_sql

      where("( referral_reports.id IN (#{subquery}) ) ").order("referral_reports.id DESC")
    end
    
    def self.since str_date
      date = DateTime.parse(str_date)
      where(["referral_reports.created_at >= :date", :date => date ])
    end
    
    def self.between from_str, to_str
      reports = self.where("1=1")

      if(!from_str.blank?)
        from = Time.parse(from_str).at_beginning_of_day # start from the beginning of the day
        reports = reports.where(["referral_reports.created_at >= :from ", :from => from ])
      end

      if !to_str.blank?
        to   = Time.parse(to_str).at_beginning_of_day
        to   = to + 1.day # must be less than from the beginning of the next day and 
        reports = reports.where(["referral_reports.created_at < :to ", :to => to]) 
      end
      reports
      
    end
    
    def self.as_csv
       CSV.generate do |csv|
        colunm_names = ["Slip code", "From", "Text", "Ignored?", "Confirmed?", "Error?"]
        5.times.each do |i| 
          colunm_names << Referral::Field.label(i+1) 
        end
        colunm_names << "Date"
        
        csv << colunm_names
        
        all.each do |report|
          row  = [ report.slip_code,
                   report.type,
                   report.text,
                   report.ignored ? "Yes" : "No",
                   report.confirm_from ? report.confirm_from.phone_number + "(#{report.confirm_from.user_name})" : "",
                   report.error ?  "Yes" : "No" ,
          ]
           
          5.times.each do |i|
            row << (report.send("field#{i+1}") || "")
          end  
          
          row << report.created_at         
          csv << row   
        end
 
      end
    end
    
  end
end
