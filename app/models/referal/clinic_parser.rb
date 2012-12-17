class Referal::ClinicParser < Referal::Parser
   attr_accessor :report
  
   def initialize options
     super(options)  
   end
   
   def parse
      begin
        create_scanner 
        scan_phone_number
        scan_slip_code
        scan_health_center 
      rescue 
      end
      create_report
   end
   
   def create_report
     @report = Referal::ClinicReport.new @options
     @report
   end
   
end
