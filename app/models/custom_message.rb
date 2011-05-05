class CustomMessage
  attr_accessor :type, :sms, :errors
  
  ErrorTypes ={
    :sms_140 => "must be less than 140 characters",
    :sms_blank => "must not be empty"
  }
  def initialize attrib
    @type = attrib[:type]
    @sms  = attrib[:sms]
    @errors = {}
  end

  def valid?
    if( ! Place::Types.include? @type)
      @errors[:type] ||= [];
      @errors[:type] << "must be in (#{Place::Types.join(", ")})"
    end

    if(@sms.strip().size == 0)
      @errors[:sms] ||= []
      @errors[:sms] <<  CustomMessage::ErrorTypes[:sms_blank]
    end

    if(@sms.strip().size > 140)
      @errors[:sms] ||= [];
      @errors[:sms] <<  CustomMessage::ErrorTypes[:sms_140]
    end
    
    return @errors.size == 0
    
  end

  def send_to user
    begin
      nuntium = Nuntium.new_from_config()
      message = {
                :from => "sms://md0",
                :subject => "",
                :body => @sms,
                :to => user.phone_number.with_sms_protocol
      }
      nuntium.send_ao message
    rescue
      
    end

  end

end