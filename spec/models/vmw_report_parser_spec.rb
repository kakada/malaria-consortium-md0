require 'spec_helper'
describe VMWReportParser do
  describe "scan patient" do
    it "should find as mobile patient" do
      parser = VMWReportParser.new(:text => "F12M")
      scanner = StringScanner.new "."
      parser.stub!(:scanner).and_return(scanner)
      parser.scan_patient
      parser.options[:mobile].should eq true
    end
    
    it "should find as mobile patient" do
      parser = VMWReportParser.new(:text => "F12M")
      scanner = StringScanner.new ""
      parser.stub!(:scanner).and_return(scanner)
      parser.scan_patient
      parser.options[:mobile].should eq false
    end
    
    it "should raise exception :too_long_vmw_report" do
        parser = VMWReportParser.new(:text => "x12M")
        scanner = StringScanner.new "xxxxxx"
        parser.stub!(:scanner).and_return(scanner)
        expect{parser.scan_patient}.to raise_error(Exception, "too_long_vmw_report")
        parser.options[:error].should eq true
        parser.options[:error_message].should eq :too_long_vmw_report
    end 
  end
  
  describe "parse" do
    it "should parse message and created report" do
      parser = VMWReportParser.new(:text => "F12M3.")
      report = parser.parse
      parser.options.should eq :text=>"F12M3.", :malaria_type=>"F", :age=>"12", :sex=>"M", :day=>3, :mobile=>true
      parser.report.should be_kind_of VMWReport
    end
  end
end
