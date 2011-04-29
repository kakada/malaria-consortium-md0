# coding: utf-8
class PlacesController < ApplicationController
  before_filter :authenticate_admin
  
  #POST /places/confirm_import
  def confirm_import
    PlaceImporter.new(current_user.places_csv_file_name).import    
  end
  
  #GET /places/import
  def import
    @title = "Upload"
  end

  #POST /places/upload_csv
  def upload_csv
    current_user.write_places_csv params[:admin][:csvfile]
    @places = PlaceImporter.new(current_user.places_csv_file_name).simulate
  
    return render 'no_places_to_import.html' if @places.nil? || @places.length == 0

    render 'upload_csv.html.erb'
  end
end