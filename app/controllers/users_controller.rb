class UsersController < ApplicationController
  before_filter :correct_user, :only => [:edit, :update]

  PerPage = 20

  #GET /users
  def index
    @title = "User management"
    @page = (params[:page] || '1').to_i
    @user = User.new
    @user.intended_place_code = ""
    @users = User.paginate :page => (@page || '1').to_i, :per_page => PerPage, :order => 'id desc'
  end

  #GET /user/new
  def new
    @title = "Create Users"
    @places = Place.all
  end

  #post /users/:id
  def destroy
    user = User.find(params[:id])
    if user == current_user
      flash["msg-error"] = "You can't delete yourself. First log in as another user and delete youself."
    else
      if Report.where(:sender_id => user.id).exists?
        flash["msg-error"] = "User #{user.user_name} can't be deleted because it already sent some reports."
      else
        user.delete
        flash["msg-error"] = "User #{user.user_name} has been removed"
      end
    end
    redirect_to :action => "index"
  end

  def create_new
    attributes = {
         :user_name => params[:user_name],
         :email => params[:email],
         :password => params[:password],
         :password_confirmation => params[:password],
         :phone_number => params[:phone_number],
         :role => params[:role],
         :id => params[:id],
         :intended_place_code => params[:intended_place_code]
    }

    @user = User.new(attributes)

    if(@user.save)
      @user = User.new
      flash["msg-notice"] = "Successfully created"
      redirect_to :action => "index" , :page => @page
    else
      @user.intended_place_code = params[:intended_place_code]
      flash["msg-error"] = "Failed to create"
      @page = (params[:page] || '1').to_i
      @users = User.paginate :page => @page, :per_page => PerPage, :order => 'id desc'
      render :index
    end
  end

  #GET user/:id.:format
  def show
    @user = User.find(params[:id])
    respond_to do |format|
	    format.json { render :json => @user  }
      format.html { render :show => @user }
    end
  end

  def user_cancel
    @user = User.find(params[:id].to_i)
    render :layout => false
  end

  #edit/:id
  def user_edit
    @user = User.find params[:id]
    render :layout => false
  end

  def user_save
    attributes = {
         :user_name => params[:user_name],
         :email => params[:email],
         :password => params[:password],
         :password_confirmation => params[:password],
         :phone_number => params[:phone_number],
         :role => params[:role],
         :id => params[:id],
         :intended_place_code => params[:intended_place_code]
    }
    @user = User.find(params[:id].to_i)
    @msg = {}

    if(@user.update_attributes(attributes))
      @user.reload #reload the user with its related model(place model)
      @msg["msg-notice"] = "Update successfully."
      render :user_cancel, :layout => false
    else
      @msg["msg-error"] = "Failed to update."
      @user[:intended_place_code] =  params[:intended_place_code]
      render :user_edit, :layout => false
    end
  end

  def mark_as_investigated
    user = User.find params[:id]
    user.last_report = nil
    user.last_report_error = false
    user.save!

    redirect_to reports_path(params.slice(:error, :place, :page)), :notice => 'Report marked as investigated'
  end

  #GET /users/csv_template
  def csv_template
    column_headers = "Name,Email,Phone,Password,Place code,Role"
    send_data column_headers, :type => 'text/csv', :filename => 'users_template.csv'
  end


  def upload_csv
    @file_name = params[:user][:csvfile].original_filename
    if @file_name.scan(/\.csv$/i).size == 0
       render :text => "Not valid csv file extension"
    else
       file = get_user_csv_path @file_name
       FileUtils.mv params[:user][:csvfile].path, file
       @users = UserImporter.parse(file)
       render "upload_csv.html.erb"
    end
  end

  def confirm_import()
    file_name = params[:file]
    file = get_user_csv_path(file_name)
    count = UserImporter.import(file)
    flash[:notice] = "#{count} users have been added "
    redirect_to :controller => :users
  end

  private

  def get_user_csv_path file_name
     File.join Rails.root, "tmp", file_name
  end
  
end
