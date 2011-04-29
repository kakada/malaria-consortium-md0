class AlertsController < ApplicationController
  before_filter :authenticate_admin, :prepare_context

  def create
    alert = HealthCenterAlert.new params[:alert]
    
    if alert.save
      flash.notice = "A new alert for #{alert.recipient.description} has been created"
    else
      flash.alert = "Could not create alert"
    end
    
    redirect_to :health_center_alerts
  end
  
  def edit
    render :health_center
  end
  
  def update
    if @alert.update_attributes(params[:alert])
      flash.notice = "The alert was updated"
    else
      flash.alert = "Could not update alert"
    end
    
    redirect_to :health_center_alerts
  end
  
  def destroy    
    if @alert.destroy
      flash.notice = "The alert was deleted"
    else
      flash.alert = "Could not delete alert"
    end

    redirect_to :health_center_alerts
  end
  
  private
  
  def prepare_context
    @ods = OD.all
    
    @alert = HealthCenterAlert.find_by_id params[:id] unless params[:id].nil?
    @alert ||= HealthCenterAlert.new 
    
    @alert.recipient = OD.find_by_id(params[:od_id]) unless params[:od_id].nil?
    @alert.recipient = @ods.first if @alert.recipient.nil?

    @hcs = @alert.recipient.health_centers    
    @alerts = HealthCenterAlert.all
  end
end
