require 'spec_helper'

describe ReportParser do
  include Helpers
  
  describe "invalid message" do
    before(:each) do
      @health_center = health_center("hc1")
      @user = user :phone_number => "1", :place => @health_center
      @parser = ReportParser.new @user
    end
    
    def assert_error_message error_message
      @parser.errors?().should == true
      @parser.error.should == error_message
    end
    
    it "should return error message invalid malaria type" do
      @parser.parse "A123M"
      assert_error_message ReportParser.invalid_malaria_type("A123M")
    end

    it "should return error message invalid age" do
      @parser.parse "FAM"
      assert_error_message ReportParser.invalid_age("FAM")
    end

    it "should return error message invalid sex" do
      @parser.parse "F21J"
      assert_error_message ReportParser.invalid_sex("F21J")
    end
    
    it "should return error message invalid malaria type when report is from hc" do
      @parser.parse "d12m11111111"
      assert_error_message ReportParser.invalid_malaria_type "d12m11111111"
    end
    
    it "should support reports with heading and trailing spaces" do      
      @parser.parse "    F21M     "
      @parser.errors?().should == false
      @parser.report.malaria_type.should == "F"
      @parser.report.age.should == 21
      @parser.report.sex.should == "Male"
      @parser.report.sender_id.should == @user.id
    end  
  end
end