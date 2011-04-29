# coding: utf-8
class HomeController < ApplicationController
  before_filter :authenticate_admin
end
