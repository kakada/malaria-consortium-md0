class Report
  def self.process(message = {})
    message = message.with_indifferent_access
    error, reports = decode message

    if reports.nil?
      [{ :from => from_app, :to => message[:from], :body => error }]
    else
      reports.map { |report| { :from => from_app, :to => report[:to], :body => successful_report(report) } }
    end
  end

  def self.unknown_user original_message
    "User unknown."
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

  def self.invalid_village_code original_message
    "Invalid village code. A village code has to be an 8 digit number. Your report was #{original_message}. Please correct and send it again."
  end

  def self.non_existent_village original_message
    "The village you entered doesn't exist. Your report was #{original_message}. Please correct and send again."
  end

  def self.non_supervised_village original_message
    "The village you entered is not under supervision of your health center. Your report was #{original_message}. Please correct and send again."
  end
<<<<<<< local
  
=======

  def self.error_message
    "Couldn't process your report. Please check the code is correct and resend."
  end

>>>>>>> other
  def self.from_app
    "malariad0://system"
  end

  def self.successful_report report
    "We received your report of Malaria Type: #{report[:malaria_type]}, Age: #{report[:age]}, Sex: #{format report[:sex]}, Village: #{report[:village_code]}"
  end

  def self.format sex
    sex == 'M' ? "Male" : "Female"
  end

  private

  def self.decode message
    sender = User.find_by_phone_number message[:from].without_protocol
    return unknown_user(message[:body]) if sender.nil?

    report_data, parse_error = parse(message[:body])

    return parse_error if report_data.nil?

    village = Village.find_by_code(report_data[:village_code])
    return non_existent_village(message[:body]) if village.nil? or village.health_center_id.nil?

    return non_supervised_village(message[:body]) if sender.place_id != village.health_center_id

    recipients = [sender.phone_number.with_sms_protocol]
    recipients.concat sender.alert_numbers.map {|number| number.with_sms_protocol}

    [nil, compose_messages(recipients, report_data)]
  end

  def self.compose_messages recipients, data
    recipients.map { |address| {:to => address}.merge(data) }
  end

  def self.parse message
    #SMS Format: [Malaria Type][age][sex][8 digit Village Code]
    #Note:  Malaria Type can only be F,V,M
    #example: V23M11223344
    scanner = StringScanner.new message

    malaria_type = scanner.scan /[FVM]/i
    return nil, invalid_malaria_type(message) if malaria_type.nil?

    age = scanner.scan /\d+/
    return nil, invalid_age(message) if age.nil?

    sex = scanner.scan /[FM]/i
    return nil, invalid_sex(message) if sex.nil?

    village_code = scanner.scan /\d{8}/
    return nil, invalid_village_code(message) if village_code.nil? || !scanner.eos?

    { :malaria_type => malaria_type, :age => age, :sex => sex, :village_code => village_code }
  end
end
