class UsersController < ApplicationController

  before_filter :authenticate, :only => [:edit, :update]
  before_filter :correct_user, :only => [:edit, :update]

  
  #GET /users
  def index
    @title = "User management"
    @page = params[:page]
    @user = User.new
    @user.intended_place_code = ""
    @users = User.paginate_user @page
  end
  
  #GET /user/new
  def new
    @title = "Create Users"
    @places = Place.all
  end
  
  #post /users/:id
  def destroy
    user = User.find(params[:id])
    user.status = 0
    user.save
    flash["msg-error"] = "User has been removed"
    redirect_to :action => "index"
  end
  
  def create
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
    else
      @user.intended_place_code = params[:intended_place_code]
      flash["msg-error"] = "Failed to create"
    end
    
    @page = (params[:page].to_i < 2) ? 1 : params[:page].to_i;
    @users = User.paginate_user @page
    
    render :index 
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
      @msg["msg-notice"] = "Update successfully."
      render :user_cancel, :layout => false
    else
      @msg["msg-error"] = "Failed to update."
      @user[:intended_place_code] =  params[:intended_place_code]
      render :user_edit, :layout => false
    end
  end
end
