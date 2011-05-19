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
     @templates = {}.with_method_access
     @templates[:single_village_case_template] = Setting[:single_village_case_template]
     @templates[:single_hc_case_template] = Setting[:single_hc_case_template]
     @templates[:aggregate_village_cases_template] = Setting[:aggregate_village_cases_template]
     @templates[:aggregate_hc_cases_template] = Setting[:aggregate_hc_cases_template]
   end

   def update_template_config
     params[:templates].each do |key, value|
      Setting[key] = value
     end

     flash["notice"] = "Templates have been saved successfully"
     redirect_to :action => :template_config
   end
end
