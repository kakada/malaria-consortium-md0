class CustomMessagesController < ApplicationController

  def new
    @custom_message = CustomMessage.new :type =>"",:sms => ""
  end

  def create
    @custom_message = CustomMessage.new :type => params[:type],:sms => params[:sms]
    if @custom_message.valid?
      @places = Place.places_by_type params[:type]
      @places.each do |place|
        place.users.each do |user|
          @custom_message.send_to user
        end    
      end
      render :review
    else
      render :new
    end
  end  
end
