module Referal
  class TemplatesController < ReferalController    
    def configs
      @templates = Templates.new
    end

    def update_configs
      params[:templates].each do |key, value|
        Setting[key] = value
      end
      flash[:notice] = "Template have been saved successfully"
      redirect_to referal_templates_configs_path
    end
  end 
end
