class HCReportParser < ReportParser

  def initialize reporter
    super(reporter)
    @report = HealthCenterReport.new
  end

  def parse message
    super(message)
    return if errors?

    village_code = @scanner.scan /\d{8}/

    generate_error :invalid_village_code if village_code.nil? || !@scanner.eos?
    return if errors?

    validate_exists village_code
    return if errors?

    validate_is_supervised
    return if errors?

    @report.village = @village

    self
  end

  def self.invalid_village_code original_message
    "Invalid village code. A village code has to be an 8 digit number. Your report was #{original_message}. Please correct and send it again."
  end

  def self.non_existent_village original_message
    "The village you entered doesn't exist. Your report was #{original_message}. Please correct and send again."
  end

  def self.non_supervised_village original_message
    "The village you entered is not under supervision of your health center. Your report was #{original_message}. Please correct and send again."
  end

  private

  def validate_exists village_code
    @village = Place.find_by_code village_code
    generate_error :non_existent_village if @village.nil? || !@village.village?
  end

  def validate_is_supervised
    generate_error :non_supervised_village if @reporter.place_id != @village.parent_id
  end
end
