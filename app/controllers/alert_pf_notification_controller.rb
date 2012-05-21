class AlertPfNotificationController < ApplicationController
  # GET /alert_pf_notification
  def index
    @alerts = AlertPfNotification.where(:status => 'SENT').paginate :page => get_page, :per_page => 10, :order => 'id desc'
    render :layout => false
  end
end
