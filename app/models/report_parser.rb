class ReportParser

  attr_reader :options
  attr_reader :error

  def initialize options
    @options =  options
  end

  def errors?
    not @error.nil?
  end

  def parse 
    message = @options[:text] 
    message = message.strip.gsub(/\s/, "").gsub(",", "")
    @scanner = StringScanner.new message

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

    @options[:malaria_type] = malaria_type
    @options[:age] = age
    @options[:sex] = self.class.format_sex sex if sex
    @options[:day] = day.to_i

    self
  end

  def generate_error(symbol)
    return if errors?
    @error  = self.class.send(symbol, @options[:text])
    @options[:error] = true
    @options[:error_message] = symbol.to_s.gsub('_', ' ')
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
