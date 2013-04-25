class Referral::ClinicParser < Referral::Parser
   def initialize options
     super(options)  
   end
   
   def parse 
     begin
       scan_messages
     rescue 
     end
     create_report
   end
   
   def create_report
     @report = Referral::ClinicReport.new @options
     @report
   end
   
   def scan_slip_code slip_code  
     report = Referral::ClinicReport.no_error.not_ignored.find_by_slip_code(slip_code)
     raise_error :referral_slip_code_duplicate if report
     super(slip_code)
   end  
   
   def message_format
     clinic_format = Referral::MessageFormat.clinic
     raise_error :undefined_format_for_clinic if clinic_format.nil?
     clinic_format
   end
   
end
