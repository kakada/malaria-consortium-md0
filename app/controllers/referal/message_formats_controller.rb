module Referal
  class MessageFormatsController < ReferalController
    def index
      @clinic = Referal::MessageFormat.first
      @hc     = Referal::MessageFormat.last
    end
    
    def save
      @clinic = Referal::MessageFormat.first
      @hc     = Referal::MessageFormat.last
      
      @clinic.format = params[:referal_message_format][:clinic]
      @hc.format = params[:referal_message_format][:hc]
      
      @hc.save
      @clinic.save
      
      flash[:notice] = "Message format have been saved"
      redirect_to referal_message_formats_path
      
    end
  end
end