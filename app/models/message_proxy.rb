class MessageProxy 
 attr_accessor :params
 attr_accessor :report
  
 def without_sms_protocol number
    number.sub("sms://", "") if number
 end
 
 def text_strip body
   body = body.strip if !body.nil?
   body
 end
  
 def initialize options
    @params = { :sender_address => without_sms_protocol(text_strip(options[:from])) ,
                :text           => text_strip(options[:body])  ,
                :nuntium_token  => options[:guid] }
    @report = nil          
 end   
 
 def analyse_number
    sender = User.find_by_phone_number @params[:sender_address]  
    
    if sender.nil?
       @params[:error] = true
       @params[:error_message] = MessageProxy.unknown_user
       @params[:sender] = nil
    elsif !sender.can_report?
      @params[:error] = true
      @params[:error_message] = MessageProxy.access_denied
      @params[:sender] = sender
      @params[:place]  = sender.place 
    else
      @params[:sender] = sender
      @params[:place]  = sender.place 
    end
 end 
 
 def generate_error options

    
    if !options[:sender] 
        # no sender dont_store any report
        #save_mdo_error
        #save_referral_error
    else #  md0 has higher precedence 
        if options[:sender].is_from_md0?
           save_mdo_error
        elsif options[:sender].is_from_referral?
           save_referral_error
        end
    end
    MessageProxy.reply_error options[:error_message] , options[:sender_address]
 end
 
 def process 
    analyse_number
    return generate_error(@params) if @params[:error]
    return process_report
  end
  
  def process_report 
    if @params[:sender].is_from_both?
      @report = guess_type @params
      @report.save!
    elsif @params[:sender].is_from_md0?
      @report = Report::process(@params)
    elsif @params[:sender].is_from_referral?
      @report = Referral::Report.process(@params)
    end
    @report.generate_alerts
  end
  
  def guess_type options
      #pass option to the decode by value
      referral_report =  Referral::Report::decode options.dup
      return referral_report if !referral_report.error
      
      md0_report     =  Report::decode options.dup
      return md0_report if !md0_report.error     
      
      return referral_report   if(referral_report.parse_quality > md0_report.parse_quality) 
      return md0_report
  end
  
  def save_referral_error
    @report = Referral::Report.new @params
    @report.save(:validate => false) 
    
  end
  
  def save_mdo_error
    @report = Report.new @params
    @report.save(:validate => false) 
  end
  
  def self.reply_error error_message, to
    [{ :from => self.app_name, :to => to, :body => error_message }]
  end
  
  def self.app_name
    "malariad0://system"
  end
  
  def self.unknown_user
    "Unknow user:  user is not registered"
  end
  
  def self.access_denied
    "Access denied: this user can not do any report"
  end
end
