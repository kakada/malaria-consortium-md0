class HCReportParser < ReportParser
  V_MOBILE = "99999999"
  attr_reader :report

  def initialize options
    super(options) 
  end

  def parse
    super()
    @report = HealthCenterReport.new(@options)
    
    village_code = @scanner.scan /^(\d{8}|\d{10})$/

    generate_error :invalid_village_code and return if village_code.nil? || !@scanner.eos?
   
    if village_code == HCReportParser::V_MOBILE
      @report.village = nil
      @report.mobile = true
      # @reporter is stored in parent class ReportParser
      #@report.health_center = @reporter.health_center
    else
       @village = Village.find_by_code village_code
       generate_error :non_existent_village and return if @village.nil? || !@village.village?
       @report.village = @village
    end
    self
  end

  def self.invalid_village_code original_message
    error_message_for :invalid_village_code, original_message
  end

  def self.non_existent_village original_message
    error_message_for :non_existent_village, original_message
  end
end
