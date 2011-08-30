require 'spec_helper'

describe HCReportParser do
  include ParserHelpers

  before(:each) do
    @health_center = HealthCenter.make
    @user = @health_center.users.make 
    @parser = HCReportParser.new @user
  end

  describe "parser" do
    before(:each) do
      @village = Village.make :code => "00112233"
      @hc_user = @village.health_center.users.make :phone_number => "983838"
      
    end

    it "should parse the message with mobile patient" do
      hc_parser = HCReportParser.new @hc_user
      hc_parser.parse "m80f99999999"
      report = hc_parser.report

      report.mobile.should be_true
      report.sender_id.should eq @hc_user.id
      report.village_id.should be_nil
      report.place_id.should eq @village.health_center.id
    end

    it "should parse the message with a patient located in a village" do
      hc_parser =HCReportParser.new @hc_user
      hc_parser.parse "m80f00112233"
      
      report = hc_parser.report

      report.mobile.should be_nil
      report.village_id.should eq @village.id
      report.place_id.should eq @village.health_center.id
    end
  end

  describe "syntactic" do
    it "should return general parser error when malaria type, age or gender are invalid" do
      assert_parse_error "d12m1111111111", :invalid_malaria_type
    end

    it "should return error message invalid village code" do
      assert_parse_error "F123MAAAAAA", :invalid_village_code
    end

    it "should return error invalid village code when village code is less than 8" do
      assert_parse_error "F123M1234567", :invalid_village_code
    end

    it "should return error invalid village code when village code is more than 10" do
      assert_parse_error "F123M123456789109", :invalid_village_code
    end

    it "should return error invalid village code when village code is 9 digits" do
      assert_parse_error "F123M123456789", :invalid_village_code
    end


    it "should return valid fields when format is correct with village code is 8 digits" do
      village = @health_center.villages.make :code => '12345678'

      @parser.parse "F123M12345678"
      @parser.errors?().should == false
      @parser.report.malaria_type.should == "F"
      @parser.report.age.should == 123
      @parser.report.sex.should == "Male"
      @parser.report.village_id.should == village.id
    end

    it "should return valid fields when format is correct with village code is 10 digits" do
      village = @health_center.villages.make :code => '1234567890'

      @parser.parse "F123M1234567890"
      @parser.errors?().should == false
      @parser.report.malaria_type.should == "F"
      @parser.report.age.should == 123
      @parser.report.sex.should == "Male"
      @parser.report.village_id.should == village.id
    end
  end
  describe "semantic" do
    it "should return error message when village code doesnt exist" do
      assert_parse_error "F123M1111111111", :non_existent_village
    end

    it "should not return error message when village isnt supervised by user's health center" do
      @health_center.villages.make :code => '9876543210'

      @parser.parse "F123M9876543210"
      @parser.errors?().should == false
    end
  end
end
