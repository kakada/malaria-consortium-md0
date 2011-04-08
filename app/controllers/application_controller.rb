class ApplicationController < ActionController::Base
  protect_from_forgery

  #from rails2
  helper :all
  include SessionsHelper
  #
end
