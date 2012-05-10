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
        @alert_pf.provinces.first.should == "#{@province.id}"
      end

      it "should be observing Report#create and do not add to alert reminder" do
        @report = Report.make :province_id => @province.id, :malaria_type => "M", :error_message => nil
        @obs = ReportObserver.instance
        AlertPfNotification.should_receive(:add_reminder).with(@report).never
        @obs.after_save @report
      end

      it 'should be observing Report#create' do
        @report = Report.make :province_id => @province.id, :malaria_type => "F", :error_message => nil
        @obs = ReportObserver.instance
        AlertPfNotification.should_receive(:add_reminder).with(@report).once
        @obs.after_save @report
      end
    end
  end
end