module SessionsHelper
  def authenticate_admin!
    authenticate_user! && admin?
  end

  def correct_user
    redirect_to root_path unless current_user == User.find(params[:id])
  end

  def admin?
    current_user.admin?
  end
end
