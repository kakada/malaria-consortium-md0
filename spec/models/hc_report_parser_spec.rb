require 'spec_helper'
require 'test_helper'

describe HCReportParser do
  include Helpers

  before(:each) do
    @health_center = health_center("hc1")
    @parser = HCReportParser.new(user("1", @health_center))
  end

  def assert_error_message error_msg
    @parser.errors?().should == true
    @parser.error.should == error_msg
  end

  def expect_village code, hc_code=nil
    Place.should_receive(:find_by_code).with(code).and_return village("1", code, hc_code)
  end

  describe "syntactic" do
    it "should return error message invalid village code" do
      @parser.parse "F123MAAAAAA"
      assert_error_message HCReportParser.invalid_village_code("F123MAAAAAA")
    end

    it "should return error invalid village code when village code is longer than expected" do
      @parser.parse "F123M123456789"
      assert_error_message HCReportParser.invalid_village_code("F123M123456789")
    end

    it "should return valid fields when format is correct" do
      expect_village "12345678", @health_center.id

      @parser.parse "F123M12345678"
      @parser.errors?().should == false
      @parser.parsed_data[:malaria_type].should == "F"
      @parser.parsed_data[:age].should == "123"
      @parser.parsed_data[:sex].should == "M"
      @parser.parsed_data[:village_code] == "12345678"
      @parser.parsed_data[:human_readable_report] == HCReportParser.human_readable_report(@parser.parsed_data)
    end
  end

  describe "semantic" do
    it "should return error message when village code doesnt exist" do
      @parser.parse "F123M11111111"
      assert_error_message HCReportParser.non_existent_village("F123M11111111")
    end

    it "should return error message when village isnt supervised by user's health center" do
      expect_village "87654321"

      @parser.parse "F123M87654321"
      assert_error_message HCReportParser.non_supervised_village("F123M87654321")
    end
  end
end
