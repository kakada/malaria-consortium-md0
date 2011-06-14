class ApplicationController < ActionController::Base
  protect_from_forgery

  PerPage = 20

  #from rails2
  helper :all

  before_filter :authenticate_user!
  before_filter :set_cambodia_time_zone

  def get_page(param_key = :page)
    (params[param_key] || '1').to_i
  end

  private

  def set_cambodia_time_zone
    Time.zone = "Bangkok" # Same time zone as Cambodia
  end
end
