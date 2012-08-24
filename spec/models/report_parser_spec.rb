require 'spec_helper'

describe ReportParser do
  include ParserHelpers

  describe "invalid message" do
    before(:each) do
      @health_center = HealthCenter.make
      @user = @health_center.users.make :phone_number => "1"
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

    it "should return error message invalid day" do
      assert_parse_error "F12M", :invalid_day
    end

    it "should return error message invalid day when day is not in {0, 3, 28}" do
      assert_parse_error "F12M1", :invalid_day
    end

    it "should return error message invalid malaria type when report is from hc" do
      assert_parse_error "d12m11111111", :invalid_malaria_type
    end

    it "should support reports with heading and trailing spaces and new lines" do
      @parser.parse "    F2\n1M0     "
      @parser.errors?().should == false
      @parser.report.malaria_type.should == "F"
      @parser.report.age.should == 21
      @parser.report.sex.should == "Male"
      @parser.report.sender_id.should == @user.id
    end
    
    it "should support reports with malaria type 'N'" do
      @parser.parse "N12M3"
      @parser.errors?().should == false
      @parser.report.malaria_type.should == "N"
      @parser.report.age.should == 12
      @parser.report.sex.should == "Male"
      @parser.report.sender_id.should == @user.id
    end
    
  end
end
