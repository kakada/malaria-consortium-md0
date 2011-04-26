# coding: utf-8
class AdminController < ApplicationController
  before_filter :authenticate_admin
    
  include AdminHelper  
    
  #POST /admin/import
  def confirm_import
    PlaceImporter.new(current_user.places_csv_file_name).import    
  end
  
  #GET /admin/places/import
  def import_places
    @title ="Upload"
  end

  #POST /admin/places/upload_places_csv
  def upload_places_csv  
    current_user.write_places_csv params[:admin][:csvfile]
    @places = PlaceImporter.new(current_user.places_csv_file_name).simulate
  
    return render 'no_places_to_import.html' if @places.nil? || @places.length == 0
      
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
    @users = User.save_bulk(params[:admin])
    @validation_failed = @users.select(&:invalid?).length > 0
    render :action => :newusers
  end
end
