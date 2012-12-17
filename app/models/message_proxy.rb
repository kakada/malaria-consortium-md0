class MessageProxy 
 attr_accessor :params
  
 def initialize options
    @params = { :sender_address => options[:from] ,
                :text           => options[:body]  ,
                :nuntium_token  => options[:guid] }
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
 
 def generate_error
    options = parameterize #help rspec test. because proxy.stub!(:params) does not work with @params
    
    if !options[:sender]
        # decide errors for MD0 and Referal
        save_mdo_error
        save_referal_error
    else
        if options[:sender].is_from_md0?
          save_mdo_error
        elsif options[:sender].is_from_referal?
          save_referal_error
        end
    end
    MessageProxy.reply_error options[:error_message] , options[:sender_address]
 end
 
 def check 
    analyse_number
    return generate_error if @params[:error]
    return process_report
  end
  
 

  def process_report 
    if @params[:sender].is_from_both?
      reports = guess_type
      report = reports[0]
      report.save!
      report.generate_alerts
    elsif @params[:sender].is_from_md0?
      Report::process(@params)
    elsif @params[:sender].is_from_referal?
      Referal::Report.process(@params)
    end
  end
  
  def guess_type
    md0_report     =  Report::decode(@params)
    referal_report =  Referal::Report::decode(@params)
    
    if(md0_report.error && referal_report.error)
      
      if(md0_report.error && md0_report.error_message != "invalid_malaria_type")
        return [md0_report] 
      end
      
      if(referal_report.error  )
          if(@params[:sender].is_private_provider_role?  && referal_report.error_message !="phone_number")
            return [referal_report]
          elsif( @params[:sender].is_health_center_role?  &&  referal_report.error_message  !="referal_invalid_od" && referal_report.error_message !="referal_invalid_not_in_od"  )
            return [referal_report]
          end  
      end
      return [md0_report, referal_report]
    else
      return [md0_report]       if !md0_report.error
      return [referal_report]   if !referal_report.error
    end 
  end
  
  def save_referal_error
    report = Referal::Report.new @params
    report.save(:validate => false) 
  end
  
  def save_mdo_error
    report = Report.new @params
    report.save(:validate => false) 
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
  
  def parameterize 
    @params
  end
  
end
