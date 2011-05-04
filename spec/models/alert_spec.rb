require 'spec_helper'

describe Alert do
  describe "recipient" do
    
    before(:each) do
      @province = Province.create!
    end
    
    it "should not be nil" do
      alert = Alert.new
      alert.save
      
      alert.valid?.should be_false
      alert.errors[:recipient_id].should_not be_blank
    end
    
   it 'has to be an OD' do
      alert = Alert.new :recipient_id => @province.id
      alert.save

      alert.valid?.should be_false
      alert.errors[:recipient_id].should_not be_nil
    end
  end
  
  describe "alerts for" do
    before(:each) do      
      @od = OD.create!
      
      @hc1 = HealthCenter.create! :code => '2', :parent => @od
      @hc2 = HealthCenter.create! :code => '3', :parent => @od
       
      @user = User.create! :place => @hc1, :phone_number => '1' 
            
      @od2 = OD.create! :code => '4'
      @alert1 = Alert.create! :recipient_id => @od.id, :threshold => 2 #source == all
      @alert2 = Alert.create! :recipient_id => @od.id, :source => @hc1, :threshold => 4

      @alert3 = Alert.create! :recipient_id => @od2.id     
      
      @alert4 = Alert.create! :recipient_id => @od.id, :source => @hc2
    end
    
    it "should iterate over alerts and build response" do
      user1 = {}
      user2 = {}

      @od.stub!(:users).and_return [user1, user2]
      
      alerts = Alert.alerts_for @od, @hc1

      alerts.map(&:id).should =~ [@alert1.id, @alert2.id]
    end
  end
  
  describe "generate for" do
    before(:each) do      
      @od = OD.create!
      
      @hc1 = HealthCenter.create! :code => '2', :parent => @od
      @hc2 = HealthCenter.create! :code => '3', :parent => @od
       
      @alert1 = HealthCenterAlert.create! :recipient_id => @od.id, :threshold => 2 #source == all
      @alert2 = HealthCenterAlert.create! :recipient_id => @od.id, :source => @hc1, :threshold => 4
    end
    
    it "should iterate over alerts and build response" do
      Alert.stub(:alerts_for).and_return [@alert1, @alert2]

      @alert1.stub!(:reached_condition?).and_return false
      @alert2.stub!(:reached_condition?).and_return true
      
      user1 = {}
      user2 = {}

      @od.stub!(:users).and_return [user1, user2]
      
      alerts = Alert.generate_for @od, @hc1

      alerts.should =~ [{:message => @alert2.message, :recipients => [user1, user2]}]      
    end
  end  
  
  describe "condition reached" do
    it "should reach condition with source = all hcs" do
      recipient_od = Place.new
      recipient_od.stub!(:count_reports_since).and_return 7
      
      alert = Alert.new :recipient => recipient_od, :threshold => 7
      alert.reached_condition?.should be_true
      
      recipient_od.stub!(:count_reports_since).and_return 8
      alert.reached_condition?.should be_true
    end
    
    it "should reach condition with source = hc" do
      hc = Place.new
      hc.stub!(:count_sent_reports_since).and_return 7
      
      alert = Alert.new :source => hc, :threshold => 7
      alert.reached_condition?.should be_true
      
      hc.stub!(:count_sent_reports_since).and_return 8
      alert.reached_condition?.should be_true
    end
  end
  
  describe "condition not reached" do
    it "should not reach condition with source = all hcs" do
      recipient_od = Place.new
      recipient_od.stub!(:count_reports_since).and_return 6
      
      alert = Alert.new :recipient => recipient_od, :threshold => 7
      alert.reached_condition?.should be_false
      
      recipient_od.stub!(:count_reports_since).and_return 4
      alert.reached_condition?.should be_false
    end
    
    it "should not reach condition with source = hc" do
      hc = Place.new
      hc.stub!(:count_sent_reports_since).and_return 6
      
      alert = Alert.new :source => hc, :threshold => 7
      alert.reached_condition?.should be_false
      
      hc.stub!(:count_sent_reports_since).and_return 4
      alert.reached_condition?.should be_false
    end
  end
end
