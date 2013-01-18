class VMWReportParser < ReportParser
  
  def initialize options
    super(options)
  end
  
  def scan_patient
    if self.scanner.eos?
      @options[:mobile] = false
    else
      is_mobile_patient = self.scanner.scan /\./
      if is_mobile_patient.nil? || !self.scanner.eos?
        raise_error :too_long_vmw_report
      end
      @options[:mobile] = true
    end
  end

  def parse
    begin
      scan
      scan_patient
    rescue
    end
    create_report
  end
  
  def create_report
    @report = VMWReport.new(@options) 
    @report
  end
  
  
end
