require 'spec_helper'

describe HCReportParser do

  before(:each) do
    @health_center = HealthCenter.make
    @user = @health_center.users.make 
    @parser = HCReportParser.new @user
    @village = Village.make :code => "12345678"
  end
  
  describe "scan village" do
    it "should find village" do
      parser = HCReportParser.new(:text => "F12M")
      scanner = StringScanner.new "12345678"
      parser.stub!(:scanner).and_return(scanner)
      parser.scan_village
      parser.options[:village].should eq @village
    end
    
    it "should raise error invalid_village_code " do
      parser = HCReportParser.new(:text => "F12M")
      scanner = StringScanner.new "123456789"
      parser.stub!(:scanner).and_return(scanner)
      expect{parser.scan_village}.to raise_error(Exception, "invalid_village_code")
      parser.options[:error].should eq true
      parser.options[:error_message].should eq :invalid_village_code
    end
    
    it "should raise error non_existent_village " do
      parser = HCReportParser.new(:text => "F12M")
      scanner = StringScanner.new "12345670"
      parser.stub!(:scanner).and_return(scanner)
      expect{parser.scan_village}.to raise_error(Exception, "non_existent_village")
      parser.options[:error].should eq true
      parser.options[:error_message].should eq :non_existent_village
    end
  end
  
  describe "parse" do
    it "should parse and return report" do
      parser = HCReportParser.new(:text => "F12M012345678")
      parser.parse
      parser.options.should eq :text=>"F12M012345678", :malaria_type=>"F", 
                               :age=>"12", :sex=>"M", :day=>0, :village=>@village
      parser.report.should be_kind_of HealthCenterReport                       
    end
  end

 
end
