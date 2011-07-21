class HCReportParser < ReportParser

  def initialize reporter
    super(reporter)
    @report = HealthCenterReport.new
  end

  def parse message
    super(message)

    village_code = @scanner.scan /^(\d{8}|\d{10})$/

    generate_error :invalid_village_code and return if village_code.nil? || !@scanner.eos?

    @village = Village.find_by_code village_code
    generate_error :non_existent_village and return if @village.nil? || !@village.village?

    @report.village = @village

    self
  end

  def self.invalid_village_code original_message
    error_message_for :invalid_village_code, original_message
  end

  def self.non_existent_village original_message
    error_message_for :non_existent_village, original_message
  end
end
