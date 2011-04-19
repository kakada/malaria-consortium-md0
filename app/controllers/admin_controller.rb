# coding: utf-8
class AdminController < ApplicationController
  before_filter :authenticate
    
  include AdminHelper  
    
  #GET /admin/import
  def import
    @title ="Upload"
  end

  #POST /admin/upload_csv
  def upload_csv  
    file_name = Rails.root.join("public","placescsv", "#{current_user.id}.csv")
    File.open(file_name,"w+b") do |file|
      file.write(params[:admin][:csvfile].read)
    end
    
    @places = PlaceImporter.new(file_name).simulate
  end


  #GET /admin/users
  def users
    @title = "User management"
    
    @users = User.paginate_user params[:page]
  end
  #GET /admin/newusers
  def newusers
    @title = "Import buck users"
    @places = Place.all
  end
  def createusers
    User.save_bucks(params[:admin])
    redirect_to :action => :users
  end
end
