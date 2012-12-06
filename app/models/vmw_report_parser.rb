class VMWReportParser < ReportParser
  attr_reader :report
  
  def initialize options
    super(options)
  end

  def parse 
    super()
    @report = VMWReport.new(@options)
    if @scanner.eos?
      @report.mobile = false
    else
      is_mobile_patient = @scanner.scan /\./
      if is_mobile_patient.nil? || !@scanner.eos?
        generate_error :too_long_vmw_report
        return
      end
      @report.mobile = true
    end
  end

  def self.too_long_vmw_report original_message
    error_message_for :too_long_village_report, original_message
  end
end
