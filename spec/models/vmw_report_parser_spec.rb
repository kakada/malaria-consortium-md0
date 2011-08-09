require 'spec_helper'

describe VMWReportParser do
  include ParserHelpers

  before(:each) do
    @village = Village.make
    @parser = VMWReportParser.new User.new :place => @village
  end

  it "should return general parser error when malaria type, age or gender are invalid" do
    assert_parse_error "d12m.", :invalid_malaria_type
  end

  it "should return error message report is longer than expected" do
    assert_parse_error "F123M11111111", :too_long_vmw_report
  end

  it "should support a trailing period, which indicates the report corresponds to a mobile patient" do
    assert_parse_error "F123M..", :too_long_vmw_report
  end

  it "should support a trailing period, which indicates the report corresponds to a mobile patient" do
    assert_parse_error "F123M.D", :too_long_vmw_report
  end

  it "should support a trailing period, which indicates the report corresponds to a mobile patient" do
    @parser.parse "f123m."
    @parser.errors?().should == false
    @parser.report.malaria_type.should == "f"
    @parser.report.age.should == 123
    @parser.report.sex.should == "Male"
    @parser.report.mobile == true
  end

  it "should support a trailing period, which indicates the report corresponds to a mobile patient" do
    assert_parse_error "F123MM", :too_long_vmw_report
  end


  it "should add field :is_mobile_patient set as false if there's no trailing period" do
    @parser.parse "F123M"
    @parser.errors?().should == false
    @parser.report.mobile.should == false
  end
end
