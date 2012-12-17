class ReportParser
  
  attr_reader   :options
  attr_accessor :scanner
  attr_accessor :report
  
  def initialize options
    @options =  options
  end
  
  def has_error?
    @options[:error]
  end
  
  alias error? has_error?
  
  def create_scanner
    message = @options[:text] 
    message = message.strip.gsub(/\s/, "").gsub(",", "")
    @scanner = StringScanner.new message
  end
  
  def scan
    create_scanner
    scan_malaria_type
    scan_age
    scan_sex
    scan_day
  end
  
  def parse
    raise "Unable to parse. You need to override this method in sub class in MD0"
  end
  
  def scan_malaria_type
    malaria_type = @scanner.scan /[FVMN]/i
    if malaria_type.nil?
      raise_error :invalid_malaria_type
    else  
      @options[:malaria_type] = malaria_type
    end
    malaria_type
  end
  
  def scan_age
    age = @scanner.scan /\d+/
    if age.nil?
      raise_error :invalid_age
    else
      @options[:age] = age
    end
  end
  
  def scan_sex
    sex = @scanner.scan /[FM]/i
    if(sex.nil?)
      raise_error :invalid_sex
    else  
      @options[:sex] = sex
    end
    sex
  end
  
  def scan_day
     day = @scanner.scan /0|3|28/
     if day.nil?
       raise_error :invalid_day
     else
       @options[:day] = day.to_i
     end
     day
  end
  
  def raise_error message
    @options[:error] = true
    @options[:error_message] = message
    raise message
  end

#  def parse 
#    message = @options[:text] 
#    message = message.strip.gsub(/\s/, "").gsub(",", "")
#    @scanner = StringScanner.new message
#
#    malaria_type = @scanner.scan /[FVMN]/i
#    generate_error :invalid_malaria_type unless malaria_type
#
#    @scanner.scan /./ if error?
#
#    age = @scanner.scan /\d+/
#    generate_error :invalid_age unless age
#
#    sex = @scanner.scan /[FM]/i
#    generate_error :invalid_sex unless sex
#
#    day = @scanner.scan /0|3|28/
#    generate_error :invalid_day unless day
#
#    @scanner.scan /\D*/ if error?
#
#    @options[:malaria_type] = malaria_type
#    @options[:age] = age
#    @options[:sex] = self.class.format_sex sex if sex
#    @options[:day] = day.to_i
#    self
#  end
end
