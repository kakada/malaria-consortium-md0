require 'spec_helper'

describe ReportParser do
  before(:each) do
    
  end
  
  describe "scan malaria_type" do
    it "should return malaria_type" do
      types = ["F ","v","m","N" ]
      parser = ReportParser.new(:text => "F12M")
      types.each do |type|
        scanner = StringScanner.new type
        parser.stub!(:scanner).and_return(scanner)
        parser.scan_malaria_type
        parser.options[:malaria_type].should eq(type.strip)
      end
    end
    it "should raise exception invalid_malaria_type" do
        parser = ReportParser.new(:text => "x12M")
        scanner = StringScanner.new "invalid"
        parser.stub!(:scanner).and_return(scanner)
        expect{parser.scan_malaria_type}.to raise_error(Exception, "invalid_malaria_type")
        parser.options[:error].should eq true
        parser.options[:error_message].should eq :invalid_malaria_type
    end
  end
  
  describe "scan age" do
    it "should return age" do
      ages = ["10","1","100","122" ]
      parser = ReportParser.new(:text => "F12M")
      ages.each do |age|
        scanner = StringScanner.new age
        parser.stub!(:scanner).and_return(scanner)
        parser.scan_age
        parser.options[:age].should eq age
      end
    end
    it "should raise exception invalid_age" do
        parser = ReportParser.new(:text => "x12M")
        scanner = StringScanner.new "x12"
        parser.stub!(:scanner).and_return(scanner)
        expect{parser.scan_age}.to raise_error(Exception, "invalid_age")
        parser.options[:error].should eq true
        parser.options[:error_message].should eq :invalid_age
    end
  end
  
  describe "scan sex" do
    it "should return sex" do
      sexs = ["f", "M" ]
      parser = ReportParser.new(:text => "F12M")
      sexs.each do |sex|
        scanner = StringScanner.new sex
        parser.stub!(:scanner).and_return(scanner)
        parser.scan_sex
        parser.options[:sex].should eq sex
      end
    end
    it "should raise exception invalid_sex" do
        parser = ReportParser.new(:text => "x12M")
        scanner = StringScanner.new "x12"
        parser.stub!(:scanner).and_return(scanner)
        expect{parser.scan_sex}.to raise_error(Exception, "invalid_sex")
        parser.options[:error].should eq true
        parser.options[:error_message].should eq :invalid_sex
    end
  end
  
  describe "scan day" do
    it "should return day" do
      days = ["3", "28", "0" ]
      parser = ReportParser.new(:text => "F12M")
      days.each do |day|
        scanner = StringScanner.new day
        parser.stub!(:scanner).and_return(scanner)
        parser.scan_day
        parser.options[:day].should eq day.to_i
      end
    end
    it "should raise exception invalid_day" do
        parser = ReportParser.new(:text => "x12M")
        scanner = StringScanner.new "x12"
        parser.stub!(:scanner).and_return(scanner)
        expect{parser.scan_day}.to raise_error(Exception, "invalid_day")
        parser.options[:error].should eq true
        parser.options[:error_message].should eq :invalid_day
    end
  end
  
  describe "scan report_parser" do
    it "should return correct data" do
      parser = ReportParser.new :text => "M12F3"
      parser.scan
      parser.options.should eq :text=>"M12F3", :malaria_type=>"M", :age=>"12", :sex=>"F", :day=>3
    end
  end
  
  
  
end
