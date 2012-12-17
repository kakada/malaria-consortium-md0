require 'spec_helper'

describe Referal::ClinicParser do
  before(:each) do
    od = OD.make :abbr => "KPS"
    @hc1 = HealthCenter.make :code => "123456"
    @hc2 = HealthCenter.make :code => "000000"
    
    @user = User.make :user_name => "bopha",  :phone_number => "85597888123", :place => od
  end
  
  it "should parse message from clinic" do 
    [
      { :msg => "0971234567KPS001001123456" , 
        :result => {:phone_number=>"0971234567", :od_name=>"KPS", :code_number=>"001", :book_number => "001", :health_center_code => "123456" } 
      },
      { :msg => "012123456KPS001001000000" , 
        :result => {:phone_number=>"012123456",  :od_name=>"KPS", :code_number=>"001", :book_number => "001", :health_center_code => "000000" } 
      },
      { :msg => "0975555555KPS010100" , 
        :result => {:phone_number=>"0975555555", :od_name=>"KPS", :code_number=>"100", :book_number => "010", :health_center_code => nil  } 
      },
    ].each do |item|
      options = { :text => item[:msg], :sender => @user }
      ref_parser = Referal::ClinicParser.new options
      report = ref_parser.parse
      
      report.class.should               eq Referal::ClinicReport
      report.od_name.should             eq item[:result][:od_name]
      report.book_number.should         eq item[:result][:book_number]
      report.code_number.should         eq  item[:result][:code_number]
      report.phone_number.should        eq item[:result][:phone_number]
       
      report.health_center_code.should  eq item[:result][:health_center_code] 
      report.text.should                eq item[:msg]
      report.type.should                eq "Referal::ClinicReport"

      report.error.should               eq false
      report.error_message.should       eq nil 


      
      
      
      
    end
  end
end
