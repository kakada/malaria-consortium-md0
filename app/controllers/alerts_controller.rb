class AlertsController < ApplicationController
  before_filter :authenticate_admin
  AlertSubclasses = Alert.subclasses

  def create
    type = AlertSubclasses.select{|x| x.name == params[:alert][:type]}.first
    alert = type.new params[:alert]

    if alert.save
      flash.notice = "A new alert for #{alert.recipient.description} has been created"
    else
      flash.alert = "Could not create alert"
    end

    redirect_to_alerts_for alert
  end

  def edit
    @alert = Alert.find(params[:id])
    prepare_alert_data
    if @alert.class == HealthCenterAlert
      render :health_center
    else
      render :village
    end
  end

  def update
    @alert = Alert.find(params[:id])
    if @alert.update_attributes(params[:alert])
      flash.notice = "The alert was updated"
    else
      flash.alert = "Could not update alert"
    end

    redirect_to_alerts_for @alert
  end

  def destroy
    @alert = Alert.find(params[:id])
    if @alert.destroy
      flash.notice = "The alert was deleted"
    else
      flash.alert = "Could not delete alert"
    end

    redirect_to_alerts_for @alert
  end

  def village
    @alert = VillageAlert.new
    prepare_alert_data
  end

  def health_center
    @alert = HealthCenterAlert.new
    prepare_alert_data
  end

  private

  def prepare_alert_data
    @ods = OD.all
    @alert.recipient ||= OD.find_by_id(params[:od_id]) if params[:od_id].present?
    @alert.recipient ||= @ods.first

    if @alert.class == VillageAlert
      hcs = @alert.recipient.health_centers
      villages = Village.where(:parent_id => hcs).group_by &:parent_id
      @hcs = Hash[@alert.recipient.health_centers.map {|hc| [hc, villages[hc.id]]}]
    elsif @alert.class == HealthCenterAlert
      @hcs = @alert.recipient.health_centers
    end

    @alerts = @alert.class.includes(:recipient, :source).all.sort! do |alert1, alert2|
      if alert1.recipient.description != alert2.recipient.description
        alert1.recipient.description <=> alert2.recipient.description
      else
        alert1.source_description <=> alert2.source_description
      end
    end
  end

  def redirect_to_alerts_for(alert)
    redirect_to alert.class.name.pluralize.underscore.to_sym
  end
end
