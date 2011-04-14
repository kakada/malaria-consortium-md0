class Report
  def self.process(message = {})
    message = message.with_indifferent_access
    error, reports = decode message

    if reports.nil?
      [{ :from => from_app, :to => message[:from], :body => error }]
    else
      reports.map { |report| { :from => from_app, :to => report[:to], :body => report[:human_readable_report] } }
    end
  end

  def self.unknown_user original_message
    "User unknown."
  end
  
  def self.user_should_belong_to_hc_or_village
    "Access denied. User should either belong to a health center or be Village Malaria Worker."
  end
  
  def self.too_long_vmw_report original_message
    "The report you sent is too long. Your report was #{original_message}. Please correct and send again."
  end

  def self.from_app
    "malariad0://system"
  end

  private

  def self.decode message
    sender = User.find_by_phone_number message[:from].without_protocol.strip
    
    return unknown_user(message[:body]) if sender.nil? 
    
    return user_should_belong_to_hc_or_village if not sender.can_report?
    
    parser = sender.report_parser
    parser.parse message[:body]
    
    return parser.error if parser.errors?
    
    report_data = parser.parsed_data

    recipients = [sender.phone_number.with_sms_protocol]
    recipients.concat sender.alert_numbers.map {|number| number.with_sms_protocol}

    [nil, compose_messages(recipients, report_data)]
  end

  def self.compose_messages recipients, data
    recipients.map { |address| {:to => address}.merge(data) }
  end
end
