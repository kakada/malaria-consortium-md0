require 'spec_helper'
require 'test_helper'

describe VMWReportParser do

  before(:each) do
    @village = Village.make
    @parser = VMWReportParser.new User.new :place => @village
  end

  def assert_error_message error_message
    @parser.errors?().should == true
    @parser.error.should == error_message
  end

  it "should return general parser error when malaria type, age or gender are invalid" do
    @parser.parse "d12m."
    assert_error_message ReportParser.invalid_malaria_type "d12m."
  end

  it "should return error message report is longer than expected" do
    @parser.parse "F123M11111111"
    assert_error_message VMWReportParser.too_long_vmw_report("F123M11111111")
  end

  it "should support a trailing period, which indicates the report corresponds to a mobile patient" do
    @parser.parse "F123M."
    @parser.errors?().should == false
    @parser.report.malaria_type.should == "F"
    @parser.report.age.should == 123
    @parser.report.sex.should == "Male"
    @parser.report.mobile == true
  end

  it "should add field :is_mobile_patient set as false if there's no trailing period" do
    @parser.parse "F123M"
    @parser.errors?().should == false
    @parser.report.mobile.should == false
  end
end