module Referal
  class UsersController < ReferalController

  	def index
  		@title = "User management"
	    @page = get_page

	    sort_params = sort_params(params)
	    @revert = sort_params[:revert_dir]
	    
	    if params[:query].present?
	      @query = params[:query].strip
	    end

	    @users = User.ref_users.paginate_user :query => @query, :type => @type,
	                                :page => (@page || '1').to_i, :per_page => PerPage,
	                                :order => "#{sort_params[:field]} #{sort_params[:dir]} "
  	end

  	def edit
  		@user = User.find params[:id]
  	end

  	def update
  		@user = User.find params[:id]
  		if @user.update_params params[:user]
		  flash["notice"] = "Successfully Updated"
	      redirect_to referal_users_path
  		else
  		  flash["error"] = "Failed to update"
	      render :edit
  		end
  	end

    def new
    	@user = User.new
    end

    def create
	    @user = User.new params[:user]

	    if @user.save
	      flash["notice"] = "Successfully created"
	      redirect_to referal_users_path
	    else
	      flash["error"] = "Failed to create"
	      render :new
	    end
	end  

	def destroy
	    user = User.ref_users.find(params[:id])
		if user == current_user
	      flash["msg-error"] = "You can't delete yourself. First log in as another user and delete youself."
		elsif user.reports.exists?
		  flash["msg-error"] = "User #{user.user_name} can't be deleted because it already sent some reports."
		else
		  user.destroy
		  flash["msg-error"] = "User #{user.user_name} has been removed"
		end
		  redirect_to referal_users_path(:page => params[:page])
		end
	end
end
