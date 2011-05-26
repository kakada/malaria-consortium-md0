class ReportParser

  attr_reader :report
  attr_reader :error
  attr_reader :short_error

  def initialize reporter
    @reporter = reporter
    @report = Report.new
    @error = nil
  end

  def errors?
    not @error.nil?
  end

  def parse message
    @original_message = message
    @message = message.strip.sub(" ", "").sub(",", "")
    @scanner = StringScanner.new @message

    malaria_type = @scanner.scan /[FVM]/i
    generate_error :invalid_malaria_type if malaria_type.nil?

    return if errors?

    age = @scanner.scan /\d+/
    generate_error :invalid_age if age.nil?

    return if errors?

    sex = @scanner.scan /[FM]/i
    generate_error :invalid_sex if sex.nil?

    return if errors?

    @report.malaria_type = malaria_type
    @report.age = age
    @report.sex = self.class.format_sex sex
    @report.sender_id = @reporter.id
    @report.place_id = @reporter.place.id

    self
  end

  def generate_error(symbol)
    @error  = self.class.send(symbol, @original_message)
    @short_error = symbol.to_s.gsub('_', ' ')
  end

  def self.invalid_malaria_type original_message
    "Incorrect type of malaria. The first character of your report indicates the type of malaria. Valid malaria types are F, V and M. Your report was #{original_message}. Please correct and send it again."
  end

  def self.invalid_age original_message
    "Invalid age. We couldn't understand the age for the case you're reporting. An age has to be a number greater or equal than 0. Your report was #{original_message}. Please correct and send it again."
  end

  def self.invalid_sex original_message
    "Invalid sex. We couldn't understand the sex for the case you're reporting. Sex can be either F or M. Your report was #{original_message}. Please correct and send it again."
  end

  def self.format_sex sex
    sex.downcase == 'M'.downcase ? "Male" : "Female"
  end
end
