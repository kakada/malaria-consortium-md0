# coding: utf-8
class HomeController < ApplicationController
  before_filter :authenticate_admin!

  def index
    redirect_to reports_path
  end
end
