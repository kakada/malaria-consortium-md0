class HCReportParser < ReportParser
  V_MOBILE = "99999999"

  def initialize options
    super(options) 
  end

  def scan_village
    village_code = self.scanner.scan /^(\d{8}|\d{10})$/
    if village_code.nil? || !self.scanner.eos?
      raise_error :invalid_village_code
    end 
    
    if village_code == HCReportParser::V_MOBILE
      @options[:village] = nil
      @options[:mobile] = true
    else
       village = Village.find_by_code village_code
       if village.nil? || !village.village?
          raise_error :non_existent_village 
       end
       @options[:village] = village
    end
  end
  
  def parse 
    begin
      scan
      scan_village
    rescue
      
    end
    create_report
  end
  
  def create_report
    @report = HealthCenterReport.new(@options)
    @report
  end
end
