class MessageProxy 
  
  attr_accessor :params
  
  def initialize message_options
    @options = message_options
    
    @params = { :sender_address => @options[:from] ,
                :text         =>  @options[:body]  ,
                :nuntium_token => @options[:guid] }
  end   
  
  def check 
    sender = User.find_by_phone_number @options[:from]
    
    if sender.nil?
       @params[:error] = true
       @params[:error_message] = MessageProxy.unknown_user
       @params[:sender] = nil
    elsif !sender.can_report?
      @params[:error] = true
      @params[:error_message] = MessageProxy.access_denied
      @params[:sender] = sender
      @params[:place] = sender.place 
    else
      @params[:sender] = sender
      @params[:place] = sender.place 
    end
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
