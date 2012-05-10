require 'spec_helper'

describe AlertPfNotification do
  describe ".add_reminder" do
    before(:each) do
      @national = Country.create!({
        :name => "country",
        :name_kh => "country_kh",
        :code => "c10010",
      })

      @province = Province.create!({
        :name => "province",
        :name_kh => "province_kh",
        :code => "p10010",
      })

      @od = @province.ods.create!({
          :name=>"districtA",
          :name_kh => "district_kh",
          :code => "d10010"
      })

      @hc = @od.health_centers.create!({
        :name => "health_center",
        :name_kh => "health_center_kh",
        :code => "h10010"
      })

      @village = @hc.villages.create!({
        :name => "village",
        :name_kh => "village_kh",
        :code => "v10010"
      })

      Setting[:reminder_days] = "2"

      @alert_pf = AlertPf.create!(:provinces => ["#{@province.id}"])
    end

    it "should add alert notification reminder to send out to village user when village reminder is enabled" do
      Setting[:village_reminder] = "1"
      @village_user = @village.users.make
      @report = Report.create!({:malaria_type => "F", :sex => "Male", :age => 30, :mobile => nil, :type => "HealthCenterReport", :sender_id => 224, :place_id => 7336, :created_at => "2011-12-27 08:58:40", :updated_at => "2011-12-27 08:58:40", :village_id => @village.id, :health_center_id => @hc.id, :od_id => @od.id, :province_id => @province.id, :text => "F30m07071503", :error => false, :error_message => "Invalid sex", :sender_address => "85569860012", :country_id => @national.id, :nuntium_token => "f254ccfe-3197-9ff5-d6ee-3ef17aa68768", :ignored => false, :trigger_to_od => true})
      
      AlertPfNotification.add_reminder(@report)
      
      # assert after add_reminder
      AlertPfNotification.count.should == 1
    end

    it "should add alert notification reminder to send out to health center user when health center reminder is enabled" do
      Setting[:hc_reminder] = "1"
      @hc.users.make
      
      @report = Report.create!({:malaria_type => "F", :sex => "Male", :age => 30, :mobile => nil, :type => "HealthCenterReport", :sender_id => 224, :place_id => 7336, :created_at => "2011-12-27 08:58:40", :updated_at => "2011-12-27 08:58:40", :village_id => @village.id, :health_center_id => @hc.id, :od_id => @od.id, :province_id => @province.id, :text => "F30m07071503", :error => false, :error_message => "Invalid sex", :sender_address => "85569860012", :country_id => @national.id, :nuntium_token => "f254ccfe-3197-9ff5-d6ee-3ef17aa68768", :ignored => false, :trigger_to_od => true})

      AlertPfNotification.add_reminder(@report)

      # assert after add_reminder
      AlertPfNotification.count.should == 1
    end

    it "should add alert notification reminder to send out to od user when od reminder is enabled" do
      Setting[:od_reminder] = "1"
      @od.users.make

      @report = Report.create!({:malaria_type => "F", :sex => "Male", :age => 30, :mobile => nil, :type => "HealthCenterReport", :sender_id => 224, :place_id => 7336, :created_at => "2011-12-27 08:58:40", :updated_at => "2011-12-27 08:58:40", :village_id => @village.id, :health_center_id => @hc.id, :od_id => @od.id, :province_id => @province.id, :text => "F30m07071503", :error => false, :error_message => "Invalid sex", :sender_address => "85569860012", :country_id => @national.id, :nuntium_token => "f254ccfe-3197-9ff5-d6ee-3ef17aa68768", :ignored => false, :trigger_to_od => true})

      AlertPfNotification.add_reminder(@report)

      # assert after add_reminder
      AlertPfNotification.count.should == 1
    end

    it "should add alert notification reminder to send out to province user when provincial reminder is enabled" do
      Setting[:provincial_reminder] = "1"
      @province.users.make

      @report = Report.create!({:malaria_type => "F", :sex => "Male", :age => 30, :mobile => nil, :type => "HealthCenterReport", :sender_id => 224, :place_id => 7336, :created_at => "2011-12-27 08:58:40", :updated_at => "2011-12-27 08:58:40", :village_id => @village.id, :health_center_id => @hc.id, :od_id => @od.id, :province_id => @province.id, :text => "F30m07071503", :error => false, :error_message => "Invalid sex", :sender_address => "85569860012", :country_id => @national.id, :nuntium_token => "f254ccfe-3197-9ff5-d6ee-3ef17aa68768", :ignored => false, :trigger_to_od => true})

      AlertPfNotification.add_reminder(@report)

      # assert after add_reminder
      AlertPfNotification.count.should == 1
    end

    it "should add alert notification reminder to send out to national user when national reminder is enabled" do
      Setting[:national_reminder] = "1"
      @national.users.make

      @report = Report.create!({:malaria_type => "F", :sex => "Male", :age => 30, :mobile => nil, :type => "HealthCenterReport", :sender_id => 224, :place_id => 7336, :created_at => "2011-12-27 08:58:40", :updated_at => "2011-12-27 08:58:40", :village_id => @village.id, :health_center_id => @hc.id, :od_id => @od.id, :province_id => @province.id, :text => "F30m07071503", :error => false, :error_message => "Invalid sex", :sender_address => "85569860012", :country_id => @national.id, :nuntium_token => "f254ccfe-3197-9ff5-d6ee-3ef17aa68768", :ignored => false, :trigger_to_od => true})

      AlertPfNotification.add_reminder(@report)

      # assert after add_reminder
      AlertPfNotification.count.should == 1
    end

    it "should add alert notification reminder to send out to admin user when admin reminder is enabled" do
      Setting[:admin_reminder] = "1"
      @admin_user = User.create! :user_name => "admin@md0.com", :password => nil, :phone_number => "85569860012", :role => "admin", :email => "admin@md0.com", :status => true

      @report = Report.create!({:malaria_type => "F", :sex => "Male", :age => 30, :mobile => nil, :type => "HealthCenterReport", :sender_id => 224, :place_id => 7336, :created_at => "2011-12-27 08:58:40", :updated_at => "2011-12-27 08:58:40", :village_id => @village.id, :health_center_id => @hc.id, :od_id => @od.id, :province_id => @province.id, :text => "F30m07071503", :error => false, :error_message => "Invalid sex", :sender_address => "85569860012", :country_id => @national.id, :nuntium_token => "f254ccfe-3197-9ff5-d6ee-3ef17aa68768", :ignored => false, :trigger_to_od => true})

      AlertPfNotification.add_reminder(@report)

      # assert after add_reminder
      AlertPfNotification.count.should == 1
    end
  end

  describe "#deliver_to_user" do
    before(:each) do
      @nuntium = mock("Nuntium")
      @nuntium_token = "f254ccfe-3197-9ff5-d6ee-3ef17aa68768"
      Setting[:reminder_message] = "{malaria_type} {phone_number} {village} {health_center}"
      @body = "M 85569860012 Orrussey Banteay Neang"
      @user1 = User.make :phone_number => "85569860012"
#      @alert_pf = AlertPf.create! :provinces => []
#      @report1 = Report.make :malaria_type => "M"
      @alert = AlertPfNotification.make :user_id => @user1.id, :status => "PENDING", :send_date => Date.today

      @message = {:to => "sms://85569860012", :body => "M 85569860012 Orrussey Banteay Neang"}
    end

    it "should deliver sms alert to user" do
      @alert.should_receive(:translate_params).with(Setting[:reminder_message]).and_return(@body)
      Nuntium.should_receive(:new_from_config).and_return(@nuntium)
      @nuntium.should_receive(:send_ao).with(@message).once.and_return(@nuntium_token)

      @alert.deliver_to_user

      # assert new update value
      @alert.status.should == "SENT"
      @alert.token.should == "f254ccfe-3197-9ff5-d6ee-3ef17aa68768"
    end
  end

  describe "#translate_params" do
    before(:each) do
      @hc = HealthCenter.create!({
        :name => "Banteay Neang",
        :name_kh => "health_center_kh",
        :code => "h10010"
      })

      @village = @hc.villages.create!({
        :name => "Orrussey",
        :name_kh => "village_kh",
        :code => "v10010"
      })

      AlertPf.create! :provinces => []
      @report = Report.make :malaria_type => "M", :health_center_id => @hc.id, :village_id => @village.id
      @user = User.make :phone_number => "85569860012"
      @alert = AlertPfNotification.create! :user_id => @user.id, :report_id => @report.id, :send_date => Date.today, :status => "SEND"
      @message = "{malaria_type} {phone_number} {village} {health_center}"
    end
    
    it "should translate params in text to values" do
      @alert.translate_params(@message).should == "M 85569860012 Orrussey Banteay Neang"
    end
  end
end
