module SessionsHelper
  def signed_in?
    user = current_user
    !user.nil?
  end

  def sign_in user
    user.remember_me!
    cookies[:remember_token] = { :value => user.remember_token, :expires => 3.years.from_now.utc }
    self.current_user = user
  end

  def current_user? user
    user == current_user
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= user_from_remember_token
  end

  def user_from_remember_token
    
    remember_token = cookies[:remember_token]
    User.find_by_remember_token(remember_token) unless remember_token.nil?
  end

  def sign_out
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  def deny_access
    store_location
    flash[:error] = "Please sign in to access this page"
    redirect_to signin_sessions_path
  end

  def store_location
    session[:redirect_to] = request.fullpath
  end

  def redirect_back_or(default)
    redirect_to(session[:redirect_to] || default)
    clear_return_to
  end

  def clear_return_to
    session[:redirect_to]= nil
  end

  def authenticate
    deny_access unless signed_in?
  end

  def authenticate_admin
    deny_access unless signed_in? and admin?
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to root_path unless current_user? @user
  end

  def admin?
    current_user.role == "admin"
  end
end
