class SettingsController < ApplicationController
  def alert_config
    @title = "Alert setting"
    @provincial_alert = Setting[:provincial_alert]
    @admin_alert = Setting[:admin_alert]
    @national_alert = Setting[:national_alert]
   end

   def update_alert_config
     Setting[:provincial_alert] = params[:setting][:provincial_alert]
     Setting[:national_alert]   = params[:setting][:national_alert]
     Setting[:admin_alert]      = params[:setting][:admin_alert]

     flash["msg-notice"] = "Settings have been saved successfully"
     redirect_to alert_config_url
   end

   def template_config
     @templates = Templates.new
   end

   def update_template_config
     @templates = Templates.new params[:templates]
     if @templates.save
       flash["notice"] = "Templates have been saved successfully"
       redirect_to :action => :template_config
     else
       render :template_config
     end
   end
end
