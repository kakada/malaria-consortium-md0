class ApplicationController < ActionController::Base
  protect_from_forgery

  #from rails2
  helper :all
  include SessionsHelper

  before_filter :authenticate_admin!
  before_filter :set_cambodia_time_zone

  private

  def set_cambodia_time_zone
    Time.zone = "Bangkok" # Same time zone as Cambodia
  end
end
