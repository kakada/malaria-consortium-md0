require 'spec_helper'

describe ReportObserver do
  describe "#after_save" do
    context "report on provincial enable" do
      before(:each) do
        @province = Province.create!({
          :name => "BB",
          :name_kh => "province_kh",
          :code => "p10010"
        })
        @alert_pf = AlertPf.create! :provinces => ["#{@province.id}"]
      end

      it "should has one provincial enable" do
        @alert_pf.provinces.size.should == 1
      end

      it "should enable for BB province" do
        @alert_pf.provinces.last.should == "#{@province.id}"
      end

      it "should be observing Report#create and do not add to alert reminder when report is valid with malaria type vivax" do
        AlertPfNotification.should_receive(:add_reminder).with(anything()).never
        @report = Report.create! :ignored => false, :province_id => @province.id, :malaria_type => "V", :error_message => nil, :place_id => Place.make, :sex => "Male", :age => 30, :sender_id => User.make, :sender_address => "85569860012", :day => 0
      end
      
      it "should be observing Report#create when report is valid with malaria type faciparum" do
        AlertPfNotification.should_receive(:add_reminder).with(anything()).once
        @report = Report.create! :ignored => false, :province_id => @province.id, :malaria_type => "F", :error_message => nil, :place_id => Place.make, :sex => "Male", :age => 30, :sender_id => User.make, :sender_address => "85569860012", :day => 3
      end

      it 'should be observing Report#create when report is valid with malaria type mixed' do
        AlertPfNotification.should_receive(:add_reminder).with(anything()).once
        @report = Report.create! :ignored => false, :province_id => @province.id, :malaria_type => "M", :error_message => nil, :place_id => Place.make, :sex => "Male", :age => 30, :sender_id => User.make, :sender_address => "85569860012", :day => 28
      end

      it 'should be observing Report#create' do
        AlertPfNotification.should_receive(:remove_reminder).with(anything()).once
        @report = Report.create! :ignored => true, :province_id => @province.id, :malaria_type => "F", :error_message => nil, :place_id => Place.make, :sex => "Male", :age => 30, :sender_id => User.make, :sender_address => "85569860012", :day => 0
      end
    end
  end
end