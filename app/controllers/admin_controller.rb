# coding: utf-8
class AdminController < ApplicationController
  before_filter :authenticate_admin
    
  include AdminHelper  
    
  #GET /admin/import
  def confirm_import
    @title ="Upload"
  end
  
  #GET /admin/places/import
  def import_places
    PlaceImporter.new(current_user.places_csv_file_name).import
  end

  #POST /admin/places/upload_places_csv
  def upload_places_csv  
    current_user.write_places_csv params[:admin][:csvfile]
    @places = PlaceImporter.new(current_user.places_csv_file_name).simulate
    render 'upload_places_csv.html'
  end

  #GET /admin/users
  def users
    @title = "User management"
    
    @users = User.paginate_user params[:page]
  end
  #GET /admin/newusers
  def newusers
    @title = "Create Users"
    @places = Place.all
  end
  def createusers
    User.save_bucks(params[:admin])
    redirect_to :action => :users
  end
end
