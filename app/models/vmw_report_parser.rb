class VMWReportParser < ReportParser
  def parse message
    super(message)
    return if errors?
    
    if @scanner.eos?
      parsed_data[:is_mobile_patient] = false 
    else
      is_mobile_patient = @scanner.scan /./      
      
      @error = VMWReportParser.too_long_vmw_report(@original_message) if !@scanner.eos? || is_mobile_patient.nil?
      return if errors?
      
      parsed_data[:is_mobile_patient] = true
    end

    parsed_data[:human_readable_report] = VMWReportParser.human_readable_report @parsed_data
    self
  end
  
  def self.too_long_vmw_report original_message 
    "Your report is too long. Your report was #{original_message}. Please correct and send it again."
  end
  
  def self.human_readable_report parsed_data
    "We received your report of #{format_is_mobile parsed_data[:is_mobile_patient]} Malaria Type: #{parsed_data[:malaria_type]}, Age: #{parsed_data[:age]}, Sex: #{format_sex parsed_data[:sex]}"
  end
  
  def self.format_is_mobile is_mobile_patient
    is_mobile_patient ? "a mobile patient with" : "a non mobile patient with"
  end
end