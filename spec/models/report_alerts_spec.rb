require 'spec_helper'
require 'test_helper'

describe Report do
  include Helpers

  it "should alert single case if no threshold was specified" do
    report = Report.make
    report.alert_triggered.should == :single
  end

  it "should alert from village after threshold" do
    village = Village.make
    Threshold.create! :place => village, :place_class => Village.name, :value => 2

    Report.make(:village => village).alert_triggered.should == nil
    Report.make(:village => village).alert_triggered.should == :village
  end

  it "should alert from village after default threshold set at HC level" do
    village = Village.make
    Threshold.create! :place => village.parent, :place_class => Village.name, :value => 2

    Report.make(:village => village).alert_triggered.should == nil
    Report.make(:village => village).alert_triggered.should == :village
  end

  it "should alert from hc after threshold" do
    village = Village.make
    Threshold.create! :place => village.parent, :place_class => HealthCenter.name, :value => 2

    Report.make(:village => village).alert_triggered.should == nil
    Report.make(:village => village).alert_triggered.should == :health_center
  end

  it "should alert from village then from hc" do
    village = Village.make
    Threshold.create! :place => village.parent, :place_class => HealthCenter.name, :value => 3
    Threshold.create! :place => village, :place_class => Village.name, :value => 2

    Report.make(:village => village).alert_triggered.should == nil
    Report.make(:village => village).alert_triggered.should == :village
    Report.make(:village => village).alert_triggered.should == :health_center
    Report.make(:village => village).alert_triggered.should == :health_center
  end

  it "generate alert from village for od" do
    report = VMWReport.make
    od_user = User.make :place => report.village.get_parent(OD)
    Setting.stub(:[]).with(:single_village_case_template).and_return('{malaria_type} {sex} {age} {village} {contact_number}')

    alerts = report.generate_alerts
    alerts.should =~ [
      {:to => od_user.phone_number.with_sms_protocol, :body => "#{report.malaria_type} #{report.sex} #{report.age} #{report.village.name} #{report.sender.phone_number}"}
    ]
  end

  it "generate alert from hc for od" do
    report = HealthCenterReport.make
    od_user = User.make :place => report.village.get_parent(OD)
    Setting.stub(:[]).with(:single_hc_case_template).and_return('{malaria_type} {sex} {age} {village} {health_center} {contact_number}')

    alerts = report.generate_alerts
    alerts.should =~ [
      {:to => od_user.phone_number.with_sms_protocol, :body => "#{report.malaria_type} #{report.sex} #{report.age} #{report.village.name} #{report.place.name} #{report.sender.phone_number}"}
    ]
  end

  it "generate aggregate alert from village" do
    village = Village.make
    od_user = User.make :place => village.get_parent(OD)
    Threshold.create! :place => village, :place_class => Village.name, :value => 2
    Setting.stub(:[]).with(:single_village_case_template).and_return('')
    Setting.stub(:[]).with(:aggregate_village_cases_template).and_return('{cases} ({f_cases}, {v_cases}) {village}')

    VMWReport.make(:village => village, :malaria_type => 'V').generate_alerts.should =~ []

    VMWReport.make(:village => village, :malaria_type => 'F').generate_alerts.should =~ [
      {:to => od_user.phone_number.with_sms_protocol, :body => "2 (1, 1) #{village.name}"}
    ]

    VMWReport.make(:village => village, :malaria_type => 'F').generate_alerts.should =~ [
      {:to => od_user.phone_number.with_sms_protocol, :body => "3 (2, 1) #{village.name}"}
    ]
  end

  it "generate aggregate alert from hc" do
    village = Village.make
    od_user = User.make :place => village.get_parent(OD)
    Threshold.create! :place => village.parent, :place_class => HealthCenter.name, :value => 2
    Setting.stub(:[]).with(:single_village_case_template).and_return('')
    Setting.stub(:[]).with(:aggregate_hc_cases_template).and_return('{cases} ({f_cases}, {v_cases}) {health_center}')

    VMWReport.make(:village => village, :malaria_type => 'V').generate_alerts.should =~ []

    VMWReport.make(:village => village, :malaria_type => 'F').generate_alerts.should =~ [
      {:to => od_user.phone_number.with_sms_protocol, :body => "2 (1, 1) #{village.parent.name}"}
    ]

    VMWReport.make(:village => village, :malaria_type => 'F').generate_alerts.should =~ [
      {:to => od_user.phone_number.with_sms_protocol, :body => "3 (2, 1) #{village.parent.name}"}
    ]
  end

end