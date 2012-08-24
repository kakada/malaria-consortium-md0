class ReportParser

  attr_reader :report
  attr_reader :error

  def initialize reporter
    @reporter = reporter
    @report = Report.new
    @error = nil
  end

  def errors?
    not @error.nil?
  end

  def parse message
    @report.sender_id = @reporter.id
    @report.sender_address = @reporter.phone_number
    @report.place_id = @reporter.place.id
    @report.text = message

    @original_message = message
    #F12
    @message = message.strip.gsub(/\s/, "").gsub(",", "")
    @scanner = StringScanner.new @message

    malaria_type = @scanner.scan /[FVMN]/i
    generate_error :invalid_malaria_type unless malaria_type

    @scanner.scan /./ if errors?

    age = @scanner.scan /\d+/
    generate_error :invalid_age unless age

    sex = @scanner.scan /[FM]/i
    generate_error :invalid_sex unless sex

    day = @scanner.scan /0|3|28/
    generate_error :invalid_day unless day

    @scanner.scan /\D*/ if errors?

    @report.malaria_type = malaria_type
    @report.age = age
    @report.sex = self.class.format_sex sex if sex
    @report.day = day.to_i

    self
  end

  def generate_error(symbol)
    return if errors?

    @error  = self.class.send(symbol, @original_message)

    @report.error = true
    @report.error_message = symbol.to_s.gsub('_', ' ')
  end

  def self.error_message_for key, original_message
    Setting[key].apply :original_message => original_message
  end

  def self.invalid_malaria_type original_message
    error_message_for :invalid_malaria_type, original_message
  end

  def self.invalid_age original_message
    error_message_for :invalid_age, original_message
  end

  def self.invalid_sex original_message
    error_message_for :invalid_sex, original_message
  end

  def self.invalid_day original_message
    error_message_for :invalid_day, original_message
  end

  def self.format_sex sex
    sex.downcase == 'M'.downcase ? "Male" : "Female"
  end
end
