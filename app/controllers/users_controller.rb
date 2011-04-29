class UsersController < ApplicationController

  before_filter :authenticate, :only => [:edit, :update, :show]
  before_filter :correct_user, :only => [:edit, :update, :show]
  
  #GET /users
  def index
    @title = "User management"
    @users = User.paginate_user params[:page]
  end
  
  #GET /user/new
  def new
    @title = "Create Users"
    @places = Place.all
  end
  
  def create
    @users = User.save_bulk(params[:admin])
    @validation_failed = @users.select(&:invalid?).length > 0
    if(@validation_failed)
      render :action => :new
    else
      render :action => :list_bulk
    end
  end

  def validate
    attrib = {
         :user_name => params[:user_name],
         :email => params[:email],
         :password => params[:password],
         :password_confirmation => params[:password],
         :intended_place_code => params[:place_code],
         :phone_number => params[:phone_number]
    }
    
    user = User.new(attrib)
    user.valid?
    
    render :json => user.errors
  end
end
