require 'spec_helper'

describe Templates do
  describe "assign to single village case template" do
    it "saves and creates a Setting" do
      subject.single_village_case_template = 'Found {malaria_type}'
      subject.save.should == true

      settings = Setting.all
      settings.count.should == 1
      settings[0].param.should == 'single_village_case_template'
      settings[0].value.should == 'Found {malaria_type}'
    end

    it "doesn't save because of an incorrect template parameter" do
      subject.single_village_case_template = 'Found {something}'
      subject.save.should == false

      Setting.count.should == 0
      subject.errors.count.should == 1
      subject.errors[:single_village_case_template].should == ["Incorrect parameter: {something}"]
    end
  end
  
  describe "#get_reminder_template_message" do
    context "village malaria worker" do
      before(:each) do
        @village = Village.create!({
          :name => "village",
          :name_kh => "village_kh",
          :code => "v10010"
        })
        @user = User.make :place_id => @village.id
        
        Setting[:reminder_message_vmw] = "VMW's reminder: {original_message}, {phone_number}, {village}, {health_center}"
      end
      
      it "should get template message of VMW" do
        Templates.get_reminder_template_message(@user).should == Setting[:reminder_message_vmw]
      end
    end
    
    context "health center, operational district, provincial, national and admin" do
      before(:each) do
        @hc = HealthCenter.create!({
          :name => "health_center",
          :name_kh => "health_center_kh",
          :code => "h10010"
        })
      
        @user = User.make :place_id => @hc.id
        
        Setting[:reminder_message_hc] = "HC's reminder: {original_message}, {phone_number}, {village}, {health_center}"
      end
      
      it "should get template message of HC, OD, PHD, National, Admin" do
        Templates.get_reminder_template_message(@user).should == Setting[:reminder_message_hc]
      end
    end
  end
end

