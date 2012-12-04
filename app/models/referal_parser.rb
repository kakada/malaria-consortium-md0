class ReferalParser
  def initialize sender
    @user = sender
    @msg_component = {}
  end
  
  def create_scanner message
    @message = message 
    @scanner = StringScanner.new message
  end
  
  def parse message
    create_scanner message
    scan_phone_number
    scan_od
    scan_code_number
    scan_health_center  
    @msg_component
  end
  
  def scan_phone_number
    @msg_component[:phone_number] =  @scanner.scan(/^\d{9,10}/)
  end
  
  def scan_od
    @msg_component[:od] =  @scanner.scan(/[^\d]+/i)
  end
  
  def scan_code_number
    @msg_component[:code_number] = @scanner.scan(/^\d{6}/)
  end
  
  def scan_health_center
    @msg_component[:health_center] = @scanner.scan(/^\d{6}/)
  end
  
  def move_to pos
    @scanner.pos = pos
  end
  
end
