class UsersController < ApplicationController

  before_filter :authenticate, :only=>[:edit,:update,:show]
  before_filter :correct_user, :only=>[:edit,:update,:show]


  #@users = @placeable.users

  #GET sign-in  new_user_path
  def index
    #@users = @placeable.users
  end


  def new
		@title = "Sign up"
    @place = Place.find(param[:id])
		@user = User.new
  end

  #GET users/1/edit edit_user_path @user
  def edit
    @user = User.find(params[:id])
    @title = "Edit user"
  end

	#GET /users/1/ user_path @user
	def show
		@user = User.find params[:id]
	end

  #PUT users/1
  def update
    @user = User.find(params[:id])
    if(!@user.nil?)
      if(@user.update_attributes(params[:user]))
        flash[:success] = "Profile updated!"
        redirect_to user_path(@user)
      end
    else
      @title = "Edit user"
      render "edit"
    end
  end

  #POST user/  users_path
  def create
    @place = Place.find(1)
    @user = @place.users.build(params[:user])
    render :new
    
  end  
end
