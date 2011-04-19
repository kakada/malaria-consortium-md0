# coding: utf-8
class AdminController < ApplicationController
  before_filter :authenticate
  
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
    
    #PlaceImporter.new(file_name).import

    render :json => { :name =>params[:admin][:csvfile].original_filename }, :content_type => 'text/html'
  end


  #GET /admin/users
  def users
    @title = "User management"
    
    @users = User.paginate_user params[:page]
  end
  #GET /admin/newusers
  def newusers
    @places = Place.all
  end
  def createusers
    User.save_bucks(params[:admin])
    redirect_to :action => :users
  end

end
