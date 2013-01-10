module Referal
  class MessageFormatsController < ReferalController
    def index
      @clinic = Referal::MessageFormat.clinic
      @hc     = Referal::MessageFormat.health_center
    end
    
    def save
      @clinic = Referal::MessageFormat.clinic
      @hc     = Referal::MessageFormat.health_center
      
      @clinic.format = params[:referal_message_format][:clinic]
      @hc.format = params[:referal_message_format][:hc]
      
      @hc.save
      @clinic.save
      
      flash[:notice] = "Message format have been saved"
      redirect_to referal_message_formats_path
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
         message_parser =  Referal::ClinicParser.new options
         message_parser.message_format = Referal::MessageFormat.clinic
          
      elsif params[:type] == "hc"
         message_parser =  Referal::HCParser.new options
         message_parser.message_format = Referal::MessageFormat.health_center
      end
      message_parser
      
    end
  end
end