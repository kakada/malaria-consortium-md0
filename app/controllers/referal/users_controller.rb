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

    def new
    	@user = User.new
    end

    def create
	    @user = User.new params[:user]

	    if @user.save
	      flash["msg-notice"] = "Successfully created"
	      redirect_to referal_users_path
	    else
	      flash["msg-error"] = "Failed to create"
	      render :new
	    end
	end    
  end
end
