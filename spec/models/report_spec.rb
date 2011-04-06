require 'spec_helper'

describe Report do
  before(:each) do
    @health_center = HealthCenter.create!(:name => "foohc", :name_kh => "foohc", :code => "HC")
    @another_health_center = HealthCenter.create!(:name => "barhc", 
                                                  :name_kh => "barhc", 
                                                  :code => "barHC")

    @village = Village.create!(:name => "fooville", 
                                :name_kh => "fooville", 
                                :code => "12345678",
                                :health_center_id => @health_center.id)
    
    @another_village = Village.create!(:name => "barville", 
                                        :name_kh => "barville", 
                                        :code => "87654321",
                                        :health_center_id => @another_health_center.id)    
    
    @user = User.create!(:phone_number => "8558190", 
                          :place_id => @health_center.id, 
                          :place_type => "HealthCenter") 
  end
  
  describe "invalid message" do
    def assert_response_error message
      response = Report.process(message)
      response[:to].should == message[:from]
      response[:body].should == Report.error_message
      response[:from].should == Report.from_app
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
      message = {:from => "sms://8558190", :body => "F123M12345678"}
      response = Report.process message
      response[:to].should == message[:from]
      response[:body].should == Report.successful_report("F", 123, "Male", "12345678")
    end  
  end  
  
  
end
