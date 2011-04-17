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
      redirect_to "/users/#{@user.id}"
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


  def data_entry
    pro_takao =  Province.new(:name=>"Takao", :name_kh=>"Takao",:code => "98888881")
    pro_takao.save

    district_takao1 = District.new(:name=>"Laem1", :name_kh=>"Laem_kh1",:code => "88888881",:province_id =>pro_takao.id)
    district_takao1.save

    district_takao2 = District.new(:name=>"Laem2", :name_kh=>"Laem_kh2",:code => "88888882",:province_id =>pro_takao.id)
    district_takao2.save


    hc_takao1 = HealthCenter.new(:name=>"Hc1", :name_kh=>"Hc1_kh1",:code => "78888881",:district_id =>district_takao1.id)
    hc_takao1.save


    village1 = Village.new(:name=>"Vl1",
          :name_kh=>"Vl1",:code => "68888881",
          :district_id =>district_takao1.id,
          :health_center_id => hc_takao1.id )
    village1.save

    village2 = Village.new(:name=>"Vl2",
          :name_kh=>"Vl2",:code => "68888882",
          :district_id =>district_takao1.id,
          :health_center_id => hc_takao1.id )
    village2.save

    user_province = User.new :phone_number =>"85517808707",
                             :place_id =>pro_takao.id,
                             :type=>"Province"
    user_province.save

    user_healthcenter = User.new :phone_number =>"85511819281",
                                  :place_id => hc_takao1.id,
                                  :type => "HealthCenter"


    user_healthcenter.save






    render :text=>"success"

  end




end
