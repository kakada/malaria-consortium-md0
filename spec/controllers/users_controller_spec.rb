require "spec_helper"

describe UsersController do
  before(:each) do
      Place.create!(:name => "Phnom penh", :code => "pcode1" )
      @attribute = {
         :user_name => "admin",
         :email => "admin@yahoo.com",
         :password => "123456",
         :intended_place_code =>"pcode1",
         :phone_number => "0975553553",
         :role => User::Roles[0]
      }
      @user = User.create! @attribute
    end
  it "should use UsersController" do
    controller.should be_instance_of UsersController
  end

  describe "Delete user" do
    before(:each) do
      User.stub(:find).with(@user.id).and_return(@user)
    end
    it "should set user with status to cero " do
      delete :destroy , :id => @user.id 
      @user.status.should == 0    
    end

    it "should set flash with msg-error " do
      delete :destroy, :id =>@user.id
      flash["msg-error"].should_not be_nil
    end

    it "should redirect to index page" do
      delete :destroy, :id=>@user.id
      response.should redirect_to users_path
    end
  end
  
  #Update attribute of user
  describe "#user_save" do
    describe "with valid attributes" do
      before(:each) do
        @update_attrib_valid = @attribute.merge :id =>1
        User.stub!(:find).with(1).and_return(@user)
        @user.stub!(:update_attributes).and_return(true)
        @user.stub!(:reload)
      end
      
      it "should find user and return an user object " do
        User.should_receive(:find).with(1).and_return(@user)
        @attribute[:id] = 1
        put :user_save , @update_attrib_valid
      end

      it "should update the user with update_attributes and return true" do
        @user.should_receive(:update_attributes).and_return(true)
        put :user_save, @update_attrib_valid
      end

      it "should reload the user model to reflex place changes" do
        @user.should_receive(:reload)
        put :user_save, @update_attrib_valid
      end

      it "should set @msg as notice msg" do
        put :user_save, @update_attrib_valid
        assigns[:msg].should == {"msg-notice" => "Update successfully."}
      end

      it "should render user_cancel template" do
        put :user_save, @update_attrib_valid
        response.should render_template :user_cancel
      end

    end

    describe "with invalid attributes" do
      before(:each) do
        User.stub!(:find).with(1).and_return(@user)
        @user.stub!(:update_attributes).and_return(false)
        @update_attrib_invalid = @attribute.merge :id=>1 , :email=>"format@", :phone_number=>"eytwr"
      end

      it "should find a user and return an user obj" do
        User.should_receive(:find).with(1).and_return(@user)
        put :user_save, @update_attrib_invalid
      end

      it "should not update attribute of the user object " do
        @user.should_receive(:update_attributes).and_return(false)
        put :user_save, @update_attrib_invalid
      end

      it "should set @msg as error msg" do
        put :user_save, @update_attrib_invalid
        assigns[:msg].should  == {"msg-error" => "Failed to update."}
      end

      it "should render user_edit template" do
        put  :user_save, @update_attrib_invalid
        response.should render_template :user_edit
      end
    end
  end


  describe "user_edit form" do
    before(:each) do
      User.stub!(:find).with(1).and_return(@user)
    end

    it "should find user and return an user object" do
      User.should_receive(:find).with(1).and_return(@user)
      get :user_edit, :id=>1
    end

    it "should render user_edit template with no layout" do
      get :user_edit, :id =>1
      response.should render_template :user_edit
      response.should_not render_template  "layouts/application"
    end

  end

  describe "user_cancel form" do
    before(:each) do
      User.stub!(:find).with(1).and_return(@user)
    end

    it "should find user and return an user object" do
      User.should_receive(:find).with(1).and_return(@user)
      get :user_cancel, :id=>1
    end

    it "should render user_cancel template with no layout" do
      get :user_cancel, :id =>1
      response.should render_template :user_cancel
      response.should_not render_template  "layouts/application"
    end

  end
end