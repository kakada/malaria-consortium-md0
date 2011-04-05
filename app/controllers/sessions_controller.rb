class SessionsController < ApplicationController
  #sign in form
  def new
    @title = "Sign in"
  end

  
  def create
    @title = "Sign in"
    @user = User.authenticate(params[:session][:email], params[:session][:password])

    if @user.nil?
      flash.now[:error] = "Invalid email/password combination."
      @title = "Sign in"
      render 'new'

    else
      sign_in @user
      redirect_back_or @user
    end
  end

  #destroy
  def destroy
    sign_out
    redirect_to root_url    
  end

end
