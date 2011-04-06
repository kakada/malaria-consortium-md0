class Report
  def self.process(message = {})
    message = message.with_indifferent_access
    report = decode message
    
    if report.nil?
      reply :to => message[:from], :body => error_message
    else 
      reply :to => message[:from], :body => format(report)
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
  
  def self.format data
     if(data[:sex] == 'M')
        sex = "Male"
     else
        sex = "Female"
     end
    
    successful_report data[:malaria_type], data[:age], sex, data[:village_code]
  end  
  
  private
  
  def self.reply response
    response[:from] = from_app
    response
  end
  
  def self.decode message
    data = parse(message[:body])
    
    return nil if data.nil?
    
    return nil unless Village.exists?(["code = :code",{:code=> data[:village_code]}] )    
    
    village = Village.find_by_code(data[:village_code])
    user = User.find_by_phone_number message[:from].split('://')[1]
    return nil if user.nil? 
    return nil if village.health_center.nil?
    return nil if user.place_id != village.health_center.id
    
    data
  end 
  
  def self.parse message
    #SMS Format: [Malaria Type][age][sex][8 digit Village Code]   
    #Note:  Malaria Type can only be F,V,M
    #example: V23M11223344
    return nil unless message=~/([FVM])(\d+)([FM])(\d{8})/i
    
    data = {}
    data[:malaria_type] = $1
    data[:age] = $2
    data[:sex] = $3
    data[:village_code] = $4
    data
  end 
end