class Referal::Parser
  attr_accessor :options
  attr_accessor :report
  attr_accessor :error
  
  def has_error?
    @options[:error]
  end
  
  alias :"error?"  :"has_error?"
  
  def initialize options
    @options = options
  end
  
  def create_scanner
    @scanner = StringScanner.new @options[:text]
  end
  
  def parse
    raise "Unable to parse. You need to override this method in sub class in referal"
  end
  
  def scan_slip_code
    scan_od
    scan_book_number
    scan_code_number  
  end
  
  def from_health_center?
    @options[:sender].place.class.to_s == "HealthCenter"
  end
  
  def from_od?
    @options[:sender].place.to_s == "OD"
  end
  
  def raise_error message
    @options[:error] = true
    @options[:error_message] = message
    raise message.to_s
  end
  
  def scan_phone_number
    phone_number =  @scanner.scan(/^\d{9,10}/)
    if phone_number.nil?
      raise_error :referal_invalid_phone_number
    else  
      @options[:phone_number] = phone_number
    end
    phone_number
  end
  
  def scan_od
    od_name =  @scanner.scan(/[a-zA-Z]+/i)
    if od_name.nil?
      raise_error :referal_invalid_od 
    else
      if @options[:sender].place.abbr != od_name
        raise_error :referal_invalid_not_in_od
      else
        @options[:od_name] = od_name 
      end
    end
  end
  
  def scan_book_number
    book_number = @scanner.scan(/^\d{3}/)
    if book_number.nil?
      raise_error :referal_invalid_book_number
    else
      @options[:book_number] = book_number
    end
  end
  
  def scan_code_number
    code_number = @scanner.scan(/^\d{3}/)
    if(code_number.nil?)
      raise_error :referal_invalid_code_number
    else
      @options[:code_number] = code_number
    end
  end
  
  def scan_health_center
    if(!@scanner.eos?)
      health_center_code = @scanner.scan(/^\d{6}/)
      if health_center_code.nil?
        raise_error :referal_invalid_health_center_format
      else
        hc = HealthCenter.find_by_code health_center_code
        if hc.nil?
          raise_error :referal_invalid_health_center_code
        else
          @options[:health_center_code] = health_center_code
        end   
      end
    else
      @options[:health_center_code] = nil
    end
    @options[:health_center_code]
  end
  
  def move_to pos
    @scanner.pos = pos
  end
  
end
