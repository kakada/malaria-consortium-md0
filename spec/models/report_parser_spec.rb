require 'spec_helper'
require 'test_helper'

describe ReportParser do
  describe "invalid message" do
    before(:each) do
      @parser = ReportParser.new
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
    
    it "should support reports with heading and trailing spaces" do
      @parser.parse "    F21M     "
      @parser.errors?().should == false
      @parser.parsed_data[:malaria_type] == "F"
      @parser.parsed_data[:age] == "21"
      @parser.parsed_data[:sex] == "M"
    end  
  end
end