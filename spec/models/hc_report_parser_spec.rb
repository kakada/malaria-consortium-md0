require 'spec_helper'
require 'test_helper'

describe HCReportParser do
  include Helpers

  before(:each) do
    @health_center = HealthCenter.make
    @user = @health_center.users.make :phone_number => "1"
    @parser = HCReportParser.new @user
  end

  describe "syntactic" do
    it "should return general parser error when malaria type, age or gender are invalid" do
      assert_parse_error "d12m11111111", :invalid_malaria_type
    end

    it "should return error message invalid village code" do
      assert_parse_error "F123MAAAAAA", :invalid_village_code
    end

    it "should return error invalid village code when village code is longer than expected" do
      assert_parse_error "F123M123456789", :invalid_village_code
    end

    it "should return valid fields when format is correct" do
      village = @health_center.villages.make :code => '12345678'

      @parser.parse "F123M12345678"
      @parser.errors?().should == false
      @parser.report.malaria_type.should == "F"
      @parser.report.age.should == 123
      @parser.report.sex.should == "Male"
      @parser.report.village_id.should == village.id
      @parser.report.human_readable
    end
  end

  describe "semantic" do
    it "should return error message when village code doesnt exist" do
      assert_parse_error "F123M11111111", :non_existent_village
    end

    it "should not return error message when village isnt supervised by user's health center" do
      @health_center.villages.make :code => '87654321'

      @parser.parse "F123M87654321"
      @parser.errors?().should == false
    end
  end
end
