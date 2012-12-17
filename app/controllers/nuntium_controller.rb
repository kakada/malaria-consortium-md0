class NuntiumController < ApplicationController
  skip_filter :authenticate_user!

  before_filter :authenticate
  around_filter :transact

  def receive_at
    
    
    
    
    
    
    
    
    
    
    begin
      sender = User.check_user params[:from]
      if sender.is_from_md0?
        render :json => Report.process(params)
      elsif sender.is_from_referal?
        begin
          if(sender.is_health_center_role?)
              Reply.process(sender, params)
          elsif sender.is_private_provider_role?
              Clinic.process(sender, params)
          end
        rescue Exception => e
          
        end
      end
      
    rescue Exception => e
      # e.message
    end
  end

  private

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == Nuntium::Config['incoming_username'] && password == Nuntium::Config['incoming_password']
    end
  end

  def transact
    User.transaction do
      yield
    end
  end
end
