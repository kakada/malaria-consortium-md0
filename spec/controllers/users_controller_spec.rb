require "spec_helper"

describe UsersController do

  it "should use UsersController" do
    controller.should be_instance_of UsersController
  end
  
  describe "createusers" do
      describe "successfully created" do
        before(:each) do
          Province.create! :name => "Pro name1", :code => "Pro1"
          Province.create! :name => "Pro name2", :code => "Pro2"
          @attribs = {
              :user_name => ["foo","bar"],
              :email => ["foo@yahoo.com","bar@yahoo.com"],
              :password => ["123456", "234567"],
              :phone_number => ["0975553553", "0975425678"],
              :place_code => ["Pro1","Pro2"]
          }
          #@users = User.save_bulk(@attribs)
          #User.stub(:save_bulk).and_return(@users)
          
        end
        
        it "should redirect to users pages " do
          post :create ,:admin => @attribs
          response.should render_template :list_bulk
        end
      end
      
      describe "failed to create user" do
        before(:each) do
          @attrib = {
              :user_name => ["foo","bar"],
              :email => ["foo@yahoo.com","bar@yahoo.com"],
              :password => ["123456", "234567"],
              :phone_number => ["097 5553553", "0975425678"],
              :place_code => ["1","3"]
          }
          @valid = {
              :user_name => "admin",
              :email => "admin@yahoo.com",
              :password => "123456",
              :phone_number => "0975553553" ,
              :place_id => "855"
          }
          @user = User.create!(@valid)
        end
        it "should render newusers templates with users data" do
          post :create, :admin => @attrib
          response.should render_template "new"
        end
      end
  end
  
  describe "Validate user" do
    it "should render json" do
      Place.create!(:name => "Phnom penh", :code => "pcode1", :parent_id => 0)
      
      attrib = {
         :user_name => "admin",
         :email => "admin@yahoo.com",
         :password => "123456",
         :password_confirmation => "123456",
         :intended_place_code =>"pcode1",
         :phone_number => "0975553553"
      }
     
      get :validate, attrib
      response.content_type.should == "application/json"
    end
  end
  
  describe "newusers" do
    it "should be success at /users/new" do
      get :new
      response.should be_success
    end
  end
end