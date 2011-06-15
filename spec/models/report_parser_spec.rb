require 'spec_helper'

describe ReportParser do
  include Helpers

  describe "invalid message" do
    before(:each) do
      @health_center = HealthCenter.make
      @user = user :phone_number => "1", :place => @health_center
      @parser = ReportParser.new @user
    end

    it "should return error message invalid malaria type" do
      assert_parse_error 'A123M', :invalid_malaria_type
    end

    it "should return error message invalid age" do
      assert_parse_error 'FM', :invalid_age
    end

    it "should return error message invalid sex" do
      assert_parse_error 'F21J', :invalid_sex
    end

    it "should return error message invalid malaria type when report is from hc" do
      assert_parse_error "d12m11111111", :invalid_malaria_type
    end

    it "should support reports with heading and trailing spaces and new lines" do
      @parser.parse "    F2\n1M     "
      @parser.errors?().should == false
      @parser.report.malaria_type.should == "F"
      @parser.report.age.should == 21
      @parser.report.sex.should == "Male"
      @parser.report.sender_id.should == @user.id
    end
  end
end
