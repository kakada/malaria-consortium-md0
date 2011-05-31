class CustomMessagesController < ApplicationController
  def new
    @custom_message = CustomMessage.new :type =>"",:sms => ""
  end

  def create
    place_id = params[:place_id].to_i
    @custom_message = CustomMessage.new params[:sms]
    if(@custom_message.valid?)
      @users_places = CustomMessage.get_users place_id , params[:places]
      if params[:users]
        @users_places.concat User.find(params[:users])
      end
      @custom_message.send_sms_users @users_places
    end
  end
end
