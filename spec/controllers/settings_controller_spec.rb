require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by the Rails when you ran the scaffold generator.

describe SettingsController do
  include Devise::TestHelpers

  before(:each) do
    Setting[:provincial_alert] = "0"
    Setting[:admin_alert] = "1"
    Setting[:national_alert] = "1"

    sign_in User.make(:admin)
  end

  def mock_setting(stubs={})
    @mock_setting ||= mock_model(Setting, stubs).as_null_object
  end

  describe "GET alert_config from the setting" do
    it "should read admin_alert , provincial_alert, national_alert" do
      get :alert_config
      assigns[:provincial_alert].should == "0"
      assigns[:admin_alert].should == "1"
      assigns[:national_alert].should ==  "1"
    end

    it "should render alert_config" do
      get :alert_config
      response.should render_template :alert_config
    end
  end

  describe "GET reminder_config from the setting" do
    before(:each) do
      Setting[:admin_reminder] = "0"
      Setting[:national_reminder] = "0"
      Setting[:provincial_reminder] = "0"
      Setting[:od_reminder] = "0"
      Setting[:hc_reminder] = "1"
      Setting[:village_reminder] = "1"
      Setting[:reminder_days] = 2

      AlertPf.make(:provinces => [])
      Province.make(:type => Province.name)

      sign_in User.make(:admin)
    end

    it "should has only one provincial" do
      get :reminder_config

      assigns[:provinces].length.should == 1
    end

    it "should read admin_reminder, provicial_reminder, national_reminder" do
      get :reminder_config
      assigns[:admin_reminder].should == "0"
      assigns[:national_reminder].should == "0"
      assigns[:provincial_reminder].should == "0"
      assigns[:od_reminder].should == "0"
      assigns[:hc_reminder].should == "1"
      assigns[:village_reminder].should == "1"
      assigns[:provinces_checked].size.should == 0
      assigns[:provinces].size.should == 1
    end

    it "should render reminder_config" do
      get :reminder_config
      response.should render_template :reminder_config
    end
  end

  describe "update reminder config" do
    before(:each) do
      @attributes = {
        :setting => {
          :admin_reminder => 0,
          :national_reminder => 0,
          :provincial_reminder => 0,
          :od_reminder => 0,
          :hc_reminder => 1,
          :village_reminder => 1
        },
        :provinces => {:"1" => 1, :"2" => 2},
        :reminder_days => 2
      }

      @admin_reminder = 0
      @national_reminder = 0
      @provincial_reminder = 0
      @od_reminder = 0
      @hc_reminder = 1
      @village_reminder = 1
      @provinces = {:"1" => 1, :"2" => 2}
      @reminder_days = 2
      
      Setting.stub("[]=").with(:admin_reminder, 0).and_return(@admin_reminder)
      Setting.stub("[]=").with(:national_reminder, 0).and_return(@national_reminder)
      Setting.stub("[]=").with(:provincial_reminder, 0).and_return(@provincial_reminder)
      Setting.stub("[]=").with(:od_reminder, 0).and_return(@od_reminder)
      Setting.stub("[]=").with(:hc_reminder, 1).and_return(@hc_reminder)
      Setting.stub("[]=").with(:village_reminder, 1).and_return(@village_reminder)
      Setting.stub("[]=").with(:reminder_days, 2).and_return(@reminder_days)
    end

    it "should set the configuration properly" do
      Setting.should_receive("[]=").with(:admin_reminder, 0).and_return(@admin_reminder)
      Setting.should_receive("[]=").with(:national_reminder, 0).and_return(@national_reminder)
      Setting.should_receive("[]=").with(:provincial_reminder, 0).and_return(@provincial_reminder)
      Setting.should_receive("[]=").with(:od_reminder, 0).and_return(@od_reminder)
      Setting.should_receive("[]=").with(:hc_reminder, 1).and_return(@hc_reminder)
      Setting.should_receive("[]=").with(:village_reminder, 1).and_return(@village_reminder)
      Setting.should_receive("[]=").with(:reminder_days, 2).and_return(@reminder_days)

      post :update_reminder_config, :setting => @attributes[:setting], :reminder_days => @reminder_days, :provinces => @provinces
    end

    it "should have flash with msg-notice key" do
      post :update_reminder_config, :setting => @attributes[:setting], :reminder_days => @reminder_days, :provinces => @provinces
      flash["msg-notice"].should_not be_empty
    end

    it "should redirect to reminder_config" do
      post :update_reminder_config, :setting => @attributes[:setting], :reminder_days => @reminder_days, :provinces => @provinces
      response.should redirect_to :reminder_config
    end

  end

  describe "update alert config" do
    before(:each) do
      @attributes = {
            :provincial_alert =>1,
            :national_alert => 0,
            :admin_alert => 1
      }
      @provincial_alert = 1
      @national_alert = 0
      @admin_alert = 1

      Setting.stub("[]=").with(:provincial_alert,1).and_return(@provincial_alert)
      Setting.stub("[]=").with(:national_alert,0).and_return(@national_alert)
      Setting.stub("[]=").with(:admin_alert,1).and_return(@admin_alert)
    end

    it "should set the configurations properly" do
      Setting.should_receive("[]=").with(:provincial_alert,1).and_return(@provincial_alert)
      Setting.should_receive("[]=").with(:national_alert,0).and_return(@national_alert)
      Setting.should_receive("[]=").with(:admin_alert,1).and_return(@admin_alert)

      post :update_alert_config , :setting => @attributes
    end

    it "should have flash with msg-notice key" do
      post :update_alert_config, :setting => @attributes
      flash["msg-notice"].should_not be_empty
    end

    it "should redirect to alert_config" do
      post :update_alert_config, :setting => @attributes
      response.should redirect_to :alert_config
    end
  end
end
