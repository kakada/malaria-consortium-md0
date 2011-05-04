class VMWReportParser < ReportParser
  
  def initialize reporter
    super(reporter)
    @report = VMWReport.new
  end
  
  def parse message
    super(message)
    return if errors?
    
    if @scanner.eos?
      @report.mobile = false 
    else
      is_mobile_patient = @scanner.scan /./      
      
      @error = VMWReportParser.too_long_vmw_report(@original_message) if !@scanner.eos? || is_mobile_patient.nil?
      return if errors?
      
      @report.mobile = true
    end

    self
  end
  
  def self.too_long_vmw_report original_message 
    "Your report is too long. Your report was #{original_message}. Please correct and send it again."
  end
end