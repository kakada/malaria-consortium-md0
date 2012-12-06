class ReferalParser
  def initialize sender
    @user = sender
    @msg_component = {}
  end
  
  def create_scanner message
    @message = message 
    @msg_component = {}
    @scanner = StringScanner.new message
  end
  
  def parse_health_center message
    create_scanner message
    scan_slip_code
  end
  
  def scan_slip_code
    scan_od
    scan_book_number
    scan_code_number  
    @msg_component
  end
  
  def from_health_center?
    @user.place.class.to_s == "HealthCenter"
  end
  
  def from_od?
    @user.place.to_s == "OD"
  end
  
  def parse_clinic message
    begin
      create_scanner message
      scan_phone_number
      scan_slip_code
      scan_health_center
      @msg_component
    rescue
      
    end
  end
  
  def scan_phone_number
    phone_number =  @scanner.scan(/^\d{9,10}/)
    if phone_number.nil?
      raise "Invalid phone number"
    else  
      @msg_component[:phone_number] = phone_number
    end
    phone_number
    
  end
  
  def scan_od
    od_name =  @scanner.scan(/[a-zA-Z]+/i)
    if od_name.nil?
      raise "Invalid Od format" 
    else
      if @user.place.abbr != od_name
        raise "Invalid user is from OD #{@user.place.abbr} not #{od_name}"
      else
        @msg_component[:od_name] = od_name 
      end
    end
  end
  
  def scan_book_number
    book_number = @scanner.scan(/^\d{3}/)
    if book_number.nil?
      raise "Invalid book number"
    else
      @msg_component[:book_number] = book_number
    end
  end
  
  def scan_code_number
    code_number = @scanner.scan(/^\d{3}/)
    if(code_number.nil?)
      raise "Invalid Code number"
    else
      @msg_component[:code_number] = code_number
    end
  end
  
  def scan_health_center
    if(!@scanner.eos?)
      health_center_code = @scanner.scan(/^\d{6}/)
      if health_center_code.nil?
        raise "Invalid health center code"
      else
        @msg_component[:health_center_code] = health_center_code
      end
    else
      @msg_component[:health_center_code] = nil
    end
    @msg_component[:health_center_code]
  end
  
  def move_to pos
    @scanner.pos = pos
  end
  
end
