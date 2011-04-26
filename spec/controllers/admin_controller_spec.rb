require 'spec_helper'
require 'test_helper'

describe AdminController do
  include Helpers
  before(:each) do
    @user = admin_user "12345678"
    test_sign_in(@user) #sign the user in
    controller.signed_in?.should be_true #make sure it was signed
  end

  #Delete this example and add some real ones
  it "should use AdminController" do
    controller.should be_an_instance_of(AdminController)
  end

  describe "newusers" do
    it "should be success at /admin/newusers" do
      get :newusers
      response.should be_success
    end
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
          post :createusers ,:admin => @attribs
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
          post :createusers, :admin=> @attrib
          response.should render_template "newusers"
        end
      end
  end



  describe "Show user list admin/users" do
    it "should render the users template" do
      get :users
      response.should render_template "users"
    end
  end
  
  describe "Import places" do 
    it "should render 'no places to create' template" do
      importer_stub = {}
      PlaceImporter.stub!(:new).and_return(importer_stub)
      importer_stub.stub!(:simulate).and_return([])
      controller.current_user.stub!(:write_places_csv)
      
      post :upload_places_csv, :admin => {} 
      
      response.should render_template "no_places_to_import"
    end
  end
end
