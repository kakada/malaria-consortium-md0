require 'spec_helper'

describe Report do
  before(:each) do
    @health_center = health_center "foohc"
    village "fooville", "12345678", @health_center.id    
    village "barville", "87654321"
    
    @hc_user = user "8558190", @health_center

    @valid_message = {:from => "sms://8558190", :body => "F123M12345678"}
    @valid_recipients = ["1", "2", "3", "4", "5"]
  end
  
  describe "invalid message" do
    def assert_response_error message
      response = Report.process(message)
      
      response.is_a?(Array).should == true
      response.size.should == 1
      
      response[0][:to].should == message[:from]
      response[0][:body].should == Report.error_message
      response[0][:from].should == Report.from_app
    end
    
    it "should return error message invalid malaria type" do      
      assert_response_error :from => "sms://8558190", :body => "A123M12345678"
    end
    
    it "should return error message invalid age" do
      assert_response_error :from => "sms://8558190", :body => "FAM12345678"
    end
    
    it "should return error message invalid sex" do
      assert_response_error :from => "sms://8558190", :body => "F123J12345678"
    end
    
    it "should return error message invalid village code" do 
      assert_response_error :from => "sms://8558190", :body => "F123MAAAAAA"
    end
    
    it "should return error message when village code doesnt exist" do
      assert_response_error :from => "sms://8558190", :body => "F123M11111111"
    end
    
    it "should return error message when village isnt supervised by user's health center" do
      assert_response_error :from => "sms://8558190", :body => "F123M87654321"
    end
  end  
  
  describe "valid message" do
    it "should return the valid message with detail" do
      User.should_receive(:find_by_phone_number).with("8558190").and_return(@hc_user)
      @hc_user.stub!(:alert_numbers).and_return(@valid_recipients)

      response = Report.process @valid_message

      recipients = response.map { |reply| reply[:to] }
      recipients.should =~ [@hc_user.phone_number.to_sms_addr].concat(@valid_recipients.map {|phone_number| phone_number.to_sms_addr})

      response.each do |reply|
        reply[:from].should == Report.from_app
        reply[:body].should == Report.successful_report("F", 123, "Male", "12345678")

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

    def assert_nuntium_fields data
      [:from,:body,:to].should =~ data.keys
    end
  end    
end
