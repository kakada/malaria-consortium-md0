class Referral::HCParser < Referral::Parser
  def initialize options
    super(options)
  end
  
  def create_report
    @report = Referral::HCReport.new @options
    @report
  end
  
  def analyse_slip_code slip_code
      report = Referral::ClinicReport.find_by_slip_code(slip_code)
      raise_error :referral_slip_code_not_exist if report.nil?
  end
  
  def scan_slip_code(slip_code)
    super(slip_code)
    self.analyse_slip_code(slip_code)
  end
  
  def message_format
    hc_format = Referral::MessageFormat.health_center
    raise_error :undefined_format_for_health_center if hc_format.nil?
    return hc_format
  end
end