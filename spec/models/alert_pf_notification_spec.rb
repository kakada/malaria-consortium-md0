require 'spec_helper'

describe AlertPfNotification do
  describe ".add_reminder" do
    before(:each) do
      @report = Report.make :malaria_type => "M"
      @users = []
    end
    
    it "should create notification for all users on report" do
      AlertPfNotification.should_receive(:get_responsible_users).with(@report).and_return(@users)
      AlertPfNotification.should_receive(:create_notification).with(@users, @report).once
      AlertPfNotification.add_reminder(@report)
    end
  end
  
  describe ".create_notification" do
    before(:each) do
      @hc = HealthCenter.create!({
        :name => "health_center",
        :name_kh => "health_center_kh",
        :code => "h10010"
      })

      @village = @hc.villages.create!({
        :name => "village",
        :name_kh => "village_kh",
        :code => "v10010"
      })
      
      @users = [@village.users.make(:phone_number => "85569860012")]
      @report = Report.make :malaria_type => "M", :text => "F22m", :village_id => @village.id, :health_center_id => @hc.id
      
      @template_messaeg = "{original_message}, {phone_number}, {village}, {health_center}"
      @message = "F22m 85569860012, village, health_center"
      Setting[:reminder_days] = 2
    end
    
    it "should create notification with village user to alert pf notification" do
      Templates.should_receive(:get_reminder_template_message).with(@users[0]).and_return(@template_message)
      AlertPfNotification.any_instance.should_receive(:translate_params).with(@template_message).and_return(@message)
      
      AlertPfNotification.create_notification @users, @report
      
      # assert after create_notification
      AlertPfNotification.count.should == 1
    end
  end
  
  describe ".get_responsible_users" do
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
    end

    it "should add alert notification reminder to send out to village user when village reminder is enabled" do
      Setting[:village_reminder] = "1"
      @village_user = @village.users.make
      @report = Report.make :malaria_type => "M", :text => "F22m", :village_id => @village.id
      
      users = AlertPfNotification.get_responsible_users(@report)
      
      # assert after add_reminder
      users.count.should == 1
    end

    it "should add alert notification reminder to send out to health center user when health center reminder is enabled" do
      Setting[:hc_reminder] = "1"
      @hc.users.make
      @report = Report.make :malaria_type => "M", :text => "F22m", :village_id => @village.id
      users = AlertPfNotification.get_responsible_users(@report)

      # assert after add_reminder
      users.count.should == 1
    end

    it "should add alert notification reminder to send out to od user when od reminder is enabled" do
      Setting[:od_reminder] = "1"
      @od.users.make
      @report = Report.make :malaria_type => "M", :text => "F22m", :village_id => @village.id
      users = AlertPfNotification.get_responsible_users(@report)

      # assert after add_reminder
      users.count.should == 1
    end

    it "should add alert notification reminder to send out to province user when provincial reminder is enabled" do
      Setting[:provincial_reminder] = "1"
      @province.users.make
      @report = Report.make :malaria_type => "M", :text => "F22m", :village_id => @village.id
      users = AlertPfNotification.get_responsible_users(@report)

      # assert after add_reminder
      users.count.should == 1
    end

    it "should add alert notification reminder to send out to national user when national reminder is enabled" do
      Setting[:national_reminder] = "1"
      @national.users.make
      @report = Report.make :malaria_type => "M", :text => "F22m", :village_id => @village.id
      users = AlertPfNotification.get_responsible_users(@report)
      
      # assert after add_reminder
      users.count.should == 1
    end

    it "should add alert notification reminder to send out to admin user when admin reminder is enabled" do
      Setting[:admin_reminder] = "1"
      @admin_user = User.create! :user_name => "admin@md0.com", :password => nil, :phone_number => "85569860012", :role => "admin", :email => "admin@md0.com", :status => true
      @report = Report.make :malaria_type => "M", :text => "F22m", :village_id => @village.id
      users = AlertPfNotification.get_responsible_users(@report)

      # assert after add_reminder
      users.count.should == 1
    end
  end

  describe "#deliver_to_user" do
    before(:each) do
      @nuntium = mock("Nuntium")
      @nuntium_token = "f254ccfe-3197-9ff5-d6ee-3ef17aa68768"
      @user1 = User.make :phone_number => "85569860012"
      @alert = AlertPfNotification.make :user_id => @user1.id, :status => "PENDING", :send_date => Date.today, :message => "F22m 85569860012, village, health_center"

      @message = {:to => "sms://85569860012", :body => "F22m 85569860012, village, health_center"}
    end

    it "should deliver sms alert to user" do
      User.any_instance.should_receive(:message).with(@alert.message).and_return(@message)
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
    
      @message = "{original_message} {phone_number} {village} {health_center}"

      AlertPf.create! :provinces => []
      @user = User.make :phone_number => "85569860012", :place_id => @village.id
      
      @report = Report.make :malaria_type => "M", :text => "F22m", :health_center_id => @hc.id, :village_id => @village.id
      @alert = AlertPfNotification.create! :user_id => @user.id, :report_id => @report.id, :send_date => Date.today, :status => "SEND"
    end
    
    it "should translate params in text to values" do
      @alert.translate_params(@message).should == "F22m 85569860012 Orrussey Banteay Neang"
    end
  end
end
