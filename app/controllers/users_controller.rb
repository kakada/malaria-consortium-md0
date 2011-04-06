class UsersController < ApplicationController

  before_filter :authenticate, :only=>[:edit,:update,:show]
  before_filter :correct_user, :only=>[:edit,:update,:show]

  
  #@users = @placeable.users

  #GET sign-in  new_user_path
  def index
    @placeable = find_placeable
    #@users = @placeable.users
  end


  def new
		@title = "Sign up"
    @placeable = find_placeable
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
    @placeable = find_placeable

    @user = @placeable.users.build(params[:user])
    @user.role = @placeable.class.to_s
    
    if @user.save
      flash[:success] = "Profile page"
      sign_in(@user)
      redirect_to :id =>nil #to go to index
    else
      render :action=>:new
      @title = "Sign up"
    end  
  end

  #find_placeable type
  def find_placeable
    params.each do |name,value|
      if name =~/(.+)_id$/
        return $1.classify.constantize.find(value.to_i)
      end
    end
    nil
  end


   

end
