module Referral
  class UsersController < ReferralController

  	def index
  		@referral_title = "User management"
	    @page = get_page

	    if params[:query].present?
	      @query = params[:query].strip
	    end
      
      @users = User.includes(:place)
      if params[:all].blank?
        @users = User.ref_users
      end
      
	    @users = @users.order("updated_at DESC").paginate_user :query => @query, :type => @type,:page => (@page || '1').to_i, :per_page => PerPage
	                                
  	end
    
    def search
      @referral_title = "Search for user: #{params[:query]}"; 
	    @page = get_page

	    if params[:query].present?
	      @query = params[:query].strip
	    end
      @users = User.includes(:place).md0_users
	    @users = @users.paginate_user :query => @query, :type => @type,:page => (@page || '1').to_i, :per_page => PerPage
    end
    

  	def edit
  		@user = User.find params[:id]
      @referral_title = "Edit user- #{@user.phone_number}"
  	end

  	def update
  		@user = User.find params[:id]
  		if @user.update_params params[:user]
        flash["notice"] = "Successfully Updated"
        redirect_to params[:md0].blank? ? referral_users_path : referral_users_search_path(:query => params[:query]) 
  		else
  		  flash["error"] = "Failed to update"
	      render :edit
  		end
  	end

    def new
    	@user = User.new(:apps => [User::APP_REFERAL])
      @referral_title = "Create new user"
    end

    def create
	    @user = User.new params[:user]
      
	    if @user.save
	      flash["notice"] = "Successfully created"
	      redirect_to referral_users_path
	    else
	      flash["error"] = "Failed to create"
	      render :new
	    end
	end  

	def destroy
	    user = User.ref_users.find(params[:id])
		if user == current_user
	      flash["error"] = "You can't delete yourself. First log in as another user and delete youself."
		elsif user.reports.exists?
		  flash["error"] = "User #{user.user_name} can't be deleted because it already sent some reports."
		else
      begin 
        user.destroy
        flash["notice"] = "User #{user.user_name} has been removed"
      rescue Exception => e
        flash["error"] = "Failed to remove user : " + e.message
      end
		end
		  redirect_to referral_users_path(:page => params[:page])
		end
	end
end
