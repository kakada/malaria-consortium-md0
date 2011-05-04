require 'spec_helper'
require 'test_helper'

describe AlertsController do
  include Helpers
  
  before(:each) do
    @user = admin_user "12345678"
    test_sign_in(@user) #sign the user in
    controller.signed_in?.should be_true #make sure it was signed

    @od = OD.create!
  end
  
  def assert_flash_ok 
    flash.notice.should_not be_nil
    flash.alert.should be_nil
  end
  
  def assert_flash_error
    flash.notice.should be_nil
    flash.alert.should_not be_nil
  end
  
  describe "order" do
    before(:each) do
      od1 = OD.create! :code => 1, :name => 'F'
      od2 = OD.create! :code => 2, :name => 'A'
      od3 = OD.create! :code => 3, :name => 'D'

      hc4 = HealthCenter.create! :code => 4, :name => 'B', :parent_id => od1.id
      hc5 = HealthCenter.create! :code => 5, :name => 'C', :parent_id => od2.id
      hc6 = HealthCenter.create! :code => 6, :name => 'G', :parent_id => od2.id
      hc7 = HealthCenter.create! :code => 7, :name => 'C', :parent_id => od3.id
      
      HealthCenterAlert.create! :recipient_id => od1.id, :source_id => hc4.id
      HealthCenterAlert.create! :recipient_id => od2.id, :source_id => hc5.id      
      HealthCenterAlert.create! :recipient_id => od2.id, :source_id => hc6.id            
      HealthCenterAlert.create! :recipient_id => od3.id, :source_id => hc7.id      
    end
    
    it "should display alerts ordered by OD name and then by HC name" do
      get :health_center
      assigns(:alerts).map(&:recipient).map(&:name).should == ["A", "A", "D", "F"]
      assigns(:alerts).map(&:source).map(&:name).should == ["C", "G", "C", "B"]
    end 
  end
  
  it "should render health center template" do
    get :health_center
    response.should render_template "health_center"
  end
  
  it "should create an alert" do
    post :create, :alert => { :recipient_id => @od.id }
    
    HealthCenterAlert.count.should == 1
    
    assert_flash_ok
    response.should redirect_to health_center_alerts_path
  end
  
  it "should not create an alert" do
    post :create, :alert => { :recipient_id => nil }

    assert_flash_error
    response.should redirect_to health_center_alerts_path
  end
  
  it "should render health center template for edit" do
    get :edit, :id => 1
    response.should render_template "health_center"
  end
  
  it "should update an alert" do    
    od2 = OD.create! :code => 2
    alert = HealthCenterAlert.create! :recipient_id => @od.id

    post :update, :id => alert.id, :alert => {:recipient_id => od2.id, :threshold => 3}

    alert = HealthCenterAlert.find_by_id alert.id
    alert.recipient_id.should == od2.id
    alert.threshold.should == 3

    assert_flash_ok
    response.should redirect_to health_center_alerts_path
  end
  
  it "should not update an alert" do
    alert = HealthCenterAlert.create! :recipient_id => @od.id
        
    post :update, :id => alert.id, :alert => { :recipient_id => nil, :threshold => 3 }

    alert = HealthCenterAlert.find_by_id alert.id
    alert.recipient_id.should_not be_nil
    alert.threshold.should == 0

    assert_flash_error
    response.should redirect_to health_center_alerts_path
  end
  
  it "should destroy an alert" do
    alert = HealthCenterAlert.create! :recipient_id => @od.id
    
    delete :destroy, :id => alert.id
    
    HealthCenterAlert.count.should == 0
    
    assert_flash_ok
    response.should redirect_to health_center_alerts_path
  end  
end