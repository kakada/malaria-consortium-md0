require 'spec_helper'

describe VMWReportParser do
  include ParserHelpers

  before(:each) do
    @village = Village.make
    @parser = VMWReportParser.new User.new :place => @village
  end

  describe "too long vmw report" do
    it "should return error when report is longer than format" do
      assert_parse_error "F123M0..", :too_long_vmw_report
    end

    it "should return error when report is longer than format" do
      assert_parse_error "F123M3.D", :too_long_vmw_report
    end

    it "should return error when report is longer than format" do
      assert_parse_error "F123M2811111111", :too_long_vmw_report
    end

    it "should return error when report is longer than format" do
      assert_parse_error "F123M0M", :too_long_vmw_report
    end
  end

  it "should support a trailing period, which indicates the report corresponds to a mobile patient" do
    @parser.parse "f123m0."
    @parser.errors?().should == false
    @parser.report.malaria_type.should == "f"
    @parser.report.age.should == 123
    @parser.report.sex.should == "Male"
    @parser.report.day.should == 0
    @parser.report.mobile == true
  end

  it "should add field :is_mobile_patient set as false if there's no trailing period" do
    @parser.parse "F123M3"
    @parser.errors?().should == false
    @parser.report.day.should == 3
    @parser.report.mobile.should == false
  end
end
