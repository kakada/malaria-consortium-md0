class VMWReportParser < ReportParser

  def initialize reporter
    super(reporter)
    @report = VMWReport.new :village => reporter.place
  end

  def parse message
    super(message)

    if @scanner.eos?
      @report.mobile = false
    else
      is_mobile_patient = @scanner.scan /./

      generate_error :too_long_vmw_report and return if !@scanner.eos? || is_mobile_patient.nil?

      @report.mobile = true
    end
  end

  def self.too_long_vmw_report original_message
    error_message_for :too_long_village_report, original_message
  end
end
