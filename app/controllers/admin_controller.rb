class AdminController < ApplicationController

  #GET /admin/import
  def import
    @title ="Upload"
  end

  #POST /admin/upload_csv
  def upload_csv  
    file_name = Rails.root.join("public","placescsv", "#{current_user.id}.csv")
    File.open(file_name,"w+") do |file|
      file.write(params[:admin][:csvfile].read)
    end
    
    PlaceImporter::import(file_name)


  end

end
