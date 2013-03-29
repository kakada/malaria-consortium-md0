module Referral
  class TemplatesController < ReferralController    
    def configs
      @referral_title = "Message Template"
      @templates = Templates.new
    end

    def update_configs
      params[:templates].each do |key, value|
        Setting[key] = value
      end
      flash[:notice] = "Template have been saved successfully"
      redirect_to referral_templates_configs_path
    end
  end 
end
