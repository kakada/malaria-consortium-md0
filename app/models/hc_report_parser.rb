class HCReportParser < ReportParser
  def initialize reporter
    super()
    @reporter = reporter
  end

  def parse message

    super(message)

    village_code = @scanner.scan /\d{8}/

    @error = HCReportParser.invalid_village_code(@original_message) if village_code.nil? || !@scanner.eos?
    return if errors?

    @parsed_data[:village_code] = village_code

    validate_exists
    return if errors?

    validate_is_supervised
    return if errors?

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

  def self.human_readable_report report
    "We received your report of Malaria Type: #{report[:malaria_type]}, Age: #{report[:age]}, Sex: #{format_sex report[:sex]}, Village: #{report[:village_code]}"
  end

  private

  def validate_exists
    @village = Place.find_by_code @parsed_data[:village_code]
    @error = HCReportParser.non_existent_village(@original_message) if @village.nil? || !@village.village?
  end

  def validate_is_supervised
    @error = HCReportParser.non_supervised_village(@original_message) if @reporter.place_id != @village.parent_id
  end
end
