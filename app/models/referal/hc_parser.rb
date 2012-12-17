class Referal::HCParser < Referal::Parser
  def initialize options
    super(options)
  end
  
  def parse
    begin
      create_scanner
      scan_slip_code
    rescue 
      
    end
    create_report
  end
  
  def create_report
    @report = Referal::HCReport.new @options
  end
  
end