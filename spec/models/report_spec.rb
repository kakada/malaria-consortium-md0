require 'spec_helper'

describe Report do
  include Helpers

  before(:each) do
    @health_center = health_center "foohc"
    @village = village "fooville", "12345678", @health_center.id
    village "barville", "87654321", health_center("barhc").id

    @hc_user = user "8558190", @health_center
    @vmw_user = user "8558191", @village

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
    end

    describe "invalid syntax" do
      it "should return error message provided by parser" do
        parser = {}

        User.should_receive(:find_by_phone_number).with("8558190").and_return(@hc_user)
        @hc_user.should_receive(:report_parser).and_return(parser)
        parser.should_receive(:parse).with("F123MAAAAAA").and_return(parser)
        parser.should_receive(:errors?).and_return(true)
        parser.should_receive(:error).and_return("parser error")

        assert_response_error "parser error", :from => "sms://8558190", :body => "F123MAAAAAA"
      end
    end

    it "should return unknown user before any other error" do
      assert_response_error Report.unknown_user(""), :from => "sms://31783123", :body => ""
    end

    it "should return error when user can't report" do
      user = user "1"
      User.should_receive(:find_by_phone_number).with("1").and_return(user)
      user.should_receive(:can_report?).and_return(false)

      message = @valid_message.clone
      message[:from] = "sms://1"

      assert_response_error Report.user_should_belong_to_hc_or_village, message
    end
  end

  describe "valid message" do
    it "should return human readable message with details" do
      User.should_receive(:find_by_phone_number).with("8558190").and_return(@hc_user)
      @hc_user.stub!(:alert_numbers).and_return(@valid_recipients)

      setup_successful_parser "successful report"

      response = Report.process @valid_message

      recipients = response.map { |reply| reply[:to] }
      recipients.should =~ [@hc_user.phone_number.with_sms_protocol].concat(@valid_recipients.map {|phone_number| phone_number.with_sms_protocol})

      response.each do |reply|
        reply[:from].should == Report.from_app

        reply[:body].should == "successful report"
        assert_nuntium_fields reply
      end
    end

    it "should return an array of hashes even if there's only one hash" do
      User.should_receive(:find_by_phone_number).with("8558190").and_return(@hc_user)
      @hc_user.stub!(:alert_numbers).and_return([])

      response = Report.process @valid_message
      response.is_a?(Array).should == true
      response.size.should == 1
    end

    it "should support sender with heading and trailing spaces" do
      User.should_receive(:find_by_phone_number).with("8558190").and_return(@hc_user)
      @hc_user.stub!(:alert_numbers).and_return([])

      setup_successful_parser "successful report"

      sender_with_spaces = @valid_message.clone
      sender_with_spaces[:from] = "    sms://8558190    "

      response = Report.process sender_with_spaces
      response[0][:body].should == "successful report"
    end

    def assert_nuntium_fields data
      [:from,:body,:to].should =~ data.keys
    end

    def setup_successful_parser success_message
      parser = {}
      @hc_user.should_receive(:report_parser).and_return(parser)
      parser.should_receive(:parse).with(@valid_message[:body]).and_return(parser)
      parser.should_receive(:errors?).and_return(false)
      parser.should_receive(:parsed_data).and_return(:human_readable_report => success_message)
    end
  end
end
