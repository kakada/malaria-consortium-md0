class Report
  def self.process(message = {})
    message = message.with_indifferent_access
    reports = decode message

    if reports.nil?
      [{ :from => from_app, :to => message[:from], :body => error_message }]
    else
      reports.map { |report| { :from => from_app, :to => report[:to], :body => format(report) } }
    end
  end
  
  def self.error_message
    "Couldn't process your report. Please check the code is correct and resend."
  end 
  
  def self.from_app
    "malariad0://system" 
  end   
  
  def self.successful_report malaria_type, age, sex, village_code
    "We received your report of Malaria Type: #{malaria_type}, Age: #{age}, Sex: #{sex}, Village: #{village_code}"
  end
  
  def self.format report
    if(report[:sex] == 'M')
      sex = "Male"
    else
      sex = "Female"
    end
    successful_report report[:malaria_type], report[:age], sex, report[:village_code]
  end  
  
  private
  
  def self.decode message
    report_data = parse(message[:body])
    
    return nil if report_data.nil?
    
    village = Village.find_by_code(report_data[:village_code])
    return nil if village.nil? or village.health_center.nil?

    sender = User.find_by_phone_number message[:from].parse_phone_number
    return nil if sender.nil? or sender.place_id != village.health_center.id

    recipients = [sender.phone_number.to_sms_addr]
    recipients.concat sender.alert_numbers.map {|number| number.to_sms_addr}
    compose_messages recipients, report_data
  end



  def self.compose_messages recipients, data
    recipients.map { |address| {:to => address}.merge(data) }
  end

  def self.parse message
    #SMS Format: [Malaria Type][age][sex][8 digit Village Code]   
    #Note:  Malaria Type can only be F,V,M
    #example: V23M11223344
    return nil unless message=~/([FVM])(\d+)([FM])(\d{8})/i
    { :malaria_type => $1, :age => $2, :sex => $3, :village_code => $4 }
  end 
end