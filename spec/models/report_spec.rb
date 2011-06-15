require 'spec_helper'
require 'test_helper'

describe Report do
  include Helpers

  before(:each) do

    @province = province "Kampongcham"
    @od = @province.ods.make
    @health_center = @od.health_centers.make
    @village = @health_center.villages.make :code => '12345678'
    @health_center.villages.make :code => '87654321'

    @hc_user = user :phone_number => "8558190", :place => @health_center
    @vmw_user = user :phone_number => "8558191", :place => @village
    @od_user1 = user :phone_number => "8558192", :place => @od
    @od_user2 = user :phone_number => "8558193", :place => @od

    @provincial_user = user :phone_number => "855444444", :place => @province
    @national_user =  User.create!(:user_name =>"national", :phone_number => "097777777", :role=> "national")
    @admin_user =  User.create!(:user_name =>"admin", :phone_number => "09766666", :role=> "admin")

    @valid_message = {:from => "sms://8558190", :body => "F123M12345678"}
    @valid_vmw_message = {:from => "sms://8558191", :body => "F123M."}

    @valid_recipients = ["1", "2", "3", "4", "5"]
  end

  describe "invalid message" do
    def assert_response_error expected_response, orig_msg
      response = Report.process(orig_msg)

      response.is_a?(Array).should == true
      response.size.should == 1

      response[0][:to].should == orig_msg[:from]
      response[0][:body].should == expected_response
      response[0][:from].should == Report.from_app

      reports = Report.all
      reports.count.should eq(1)
      report = reports.first
      report.error.should be_true
    end

    it "should return unknown user before any other error" do
      assert_response_error Report.unknown_user(""), :from => "sms://31783123", :body => ""
    end

    it "should return error when user can't report" do
      user = user(:phone_number => "1")
      User.should_receive(:find_by_phone_number).with("sms://1").and_return(user)
      user.should_receive(:can_report?).and_return(false)

      message = @valid_message.clone
      message[:from] = "sms://1"

      assert_response_error Report.user_should_belong_to_hc_or_village, message
    end
  end

  describe "valid message" do
    it "should return human readable message with details" do
      User.should_receive(:find_by_phone_number).with("sms://8558190").and_return(@hc_user)

      report = setup_successful_parser "successful report"
      report.stub!(:generate_alerts).and_return([{:body => "alert1", :to => "sms://1"},
                                                  {:body => "alert2", :to => "sms://2"},
                                                  {:body => "alert3", :to => "sms://3"}])

      response = Report.process @valid_message

      @valid_message = {:from => "sms://8558190", :body => "F123M12345678"}

      report.malaria_type.should == 'F'
      report.age.should == 123
      report.sex.should == 'Male'
      report.village.should == @village
      report.sender.should == @hc_user
      report.place.should == @health_center

      response.should =~ [
                            {:to => @hc_user.phone_number.with_sms_protocol, :body => report.human_readable, :from => Report.from_app},
                            {:body => "alert1", :to => "sms://1", :from => Report.from_app},
                            {:body => "alert2", :to => "sms://2", :from => Report.from_app},
                            {:body => "alert3", :to => "sms://3", :from => Report.from_app}
                          ]

      response.each do |reply|
        assert_nuntium_fields reply
      end
    end

    it "should return an array of hashes even if there's only one hash" do
      User.should_receive(:find_by_phone_number).with("sms://8558190").and_return(@hc_user)
      report = setup_successful_parser "successful report"
      report.stub!(:generate_alerts).and_return []

      response = Report.process @valid_message
      response.is_a?(Array).should == true
      response.size.should == 1
    end

    it "should upcase malaria type" do
      report = Report.new :malaria_type => 'f', :age => 123, :sex => 'Male',
                          :village_id => @village.id, :sender_id => @hc_user.id, :place_id => @health_center.id
      report.save!
      report.malaria_type.should == 'F'
    end

    it "should notify hc when vmw reports" do
      Setting[:single_village_case_template] = 'A {malaria_type} case ({sex}, {age}) has been detected in {village} by the VMW {contact_number}'
      response = Report.process @valid_vmw_message
      hc_msg = response.select {|x| x[:to] == @hc_user.phone_number.with_sms_protocol }
      hc_msg.should have(1).items
      hc_msg[0][:body].should == "A F case (Male, 123) has been detected in #{@village.name} by the VMW #{@vmw_user.phone_number}"
    end

    def assert_nuntium_fields data
      [:from,:body,:to].should =~ data.keys
    end

    def setup_successful_parser success_message
      parser = {}
      @hc_user.should_receive(:report_parser).and_return(parser)
      parser.should_receive(:parse).with(@valid_message[:body]).and_return(parser)
      parser.should_receive(:errors?).and_return(false)

      report = Report.new :malaria_type => 'F', :age => 123, :sex => 'Male',
                          :village_id => @village.id, :sender_id => @hc_user.id, :place_id => @health_center.id

      report.stub!(:human_readable).and_return success_message

      parser.should_receive(:report).and_return(report)
      report
    end
  end
end
