require 'spec_helper'

describe Referal::HCParser do
  before(:each) do
    od = OD.make :abbr => "KPS"
    @hc1 = HealthCenter.make :code => "123456"
    @hc2 = HealthCenter.make :code => "000000"
    @user = User.make :user_name => "bopha",  :phone_number => "85597888123", :place => od
    
    
    @fieldAge = Referal::Field.create! :position => 1 , :meaning => "Age", :template => "Age temp"
    @fieldSex = Referal::Field.create! :position => 2 , :meaing  => "Sex", :template => "Sex temp"
    
    @fieldAge.constraints.build 
    
    
    
  end
  
  it "should have error with message: user not in od " do
    referal = Referal::HCParser.new :text => "HCF001001", :sender => @user
    report = referal.parse
    
    report.text.should eq "HCF001001"
    report.error.should eq true
    report.error_message.should eq :referal_invalid_not_in_od
    report.sender.should eq @user
    
  end
  
  
  it "should have error with message: wrong format" do
    referal = Referal::HCParser.new :text => "999001001", :sender => @user
    report = referal.parse
    
    report.text.should eq "999001001"
    report.error.should eq true
    report.error_message.should eq :referal_invalid_od
    report.sender.should eq @user
  end
  
  
  it "should parse message from health_center" do 
    [
      { :msg => "KPS001001" , 
        :result => {:od_name=>"KPS", :code_number=>"001", :book_number => "001", :health_center_code => nil } 
      },
      { :msg => "KPS001001" , 
        :result => {:od_name=>"KPS", :code_number=>"001", :book_number => "001", :health_center_code => nil } 
      },
      { :msg => "KPS010100" , 
        :result => {:od_name=>"KPS", :code_number=>"100", :book_number => "010", :health_center_code => nil } 
      },
    ].each do |item|
      options = { :text => item[:msg], :sender => @user }
      ref_parser = Referal::HCParser.new options
      report = ref_parser.parse
      
      report.text.should          eq item[:msg]
      report.error.should         eq false
      report.error_message.should eq nil
      
      report.od_name.should eq item[:result][:od_name]
      report.code_number.should eq item[:result][:code_number]
      report.book_number.should eq item[:result][:book_number]   
    end
  end
end
