module Referral
  class MessageFormatsController < ReferralController
    def index
      @clinic = Referral::MessageFormat.clinic
      @hc     = Referral::MessageFormat.health_center
      @referral_title = "Message Format"
    end
    
    def save
      @clinic = Referral::MessageFormat.clinic
      @hc     = Referral::MessageFormat.health_center
      
      @clinic.format = params[:referral_message_format][:clinic]
      @hc.format = params[:referral_message_format][:hc]
      
      @hc.save
      @clinic.save
      
      flash[:notice] = "Message format have been saved"
      redirect_to referral_message_formats_path
    end
    
    def test
      @message_parser = self.get_parser
      @message_parser.parse
      render :test, :layout => false
    end
    
    def get_parser 
      options = {:text => params[:text] }
      
      if !params[:sender].blank?
        options[:sender] = User.find_by_phone_number params[:sender]  
      end
      
      if params[:type] == "clinic"
         message_parser =  Referral::ClinicParser.new options
         message_parser.message_format = Referral::MessageFormat.clinic
          
      elsif params[:type] == "hc"
         message_parser =  Referral::HCParser.new options
         message_parser.message_format = Referral::MessageFormat.health_center
      end
      message_parser
    end
  end
end