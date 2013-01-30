require "spec_helper"
describe MessageProxy do
  before(:each) do
    @province = Province.make
    @od = @province.ods.make
    @health_center = @od.health_centers.make
    @village = @health_center.villages.make :code => '12345678'
    @health_center.villages.make :code => '87654321'

    @hc_user = @health_center.users.make :phone_number => "8558190", :apps => [User::APP_MDO, User::APP_REFERAL]
    @hc_user_disable_both = @health_center.users.make :phone_number => "8558199", :status => false, :apps => [User::APP_MDO, User::APP_REFERAL]
    @hc_user_disable_referral = @health_center.users.make :phone_number => "85581910", :status => false, :apps => [User::APP_REFERAL]
    
    @vmw_user = @village.users.make :phone_number => "8558191"
    @od_user_both = @od.users.make :phone_number => "8558192",  :status => true, :apps => [User::APP_MDO, User::APP_REFERAL], :role => User::ROLE_REF_PROVIDER
    @od_user_ref  = @od.users.make :phone_number => "8558193",  :status => true, :apps => [User::APP_REFERAL ], :role => User::ROLE_REF_PROVIDER

    @valid_message = {:from => "sms://8558190", :body => "F123M012345678"}
    @valid_vmw_message = {:from => "sms://8558191", :body => "F123M0."}
    
    @options = {:from => "8558190", :body => "FM12344", :guid => "AC0193740283"}
    
  end
  
  describe "Analyse the messages options" do
    it "should have error with unknown error" do
      wrong_options = @options.merge(:from => "xxx")
      proxy = MessageProxy.new wrong_options
      proxy.analyse_number
      proxy.params.should eq({  
                                :sender_address => "xxx",
                                :nuntium_token => "AC0193740283",
                                :text => "FM12344" ,
                                :error => true, 
                                :error_message => MessageProxy.unknown_user, 
                                :sender => nil
                            })  
    end
    
    it "should have error with access define for error" do
      user = @province.users.make :phone_number => "123456654321"
   

      proxy = MessageProxy.new @options.merge(:from => "123456654321")
      proxy.analyse_number
      proxy.params.should eq({ 
                              :sender_address => "123456654321",
                              :nuntium_token => "AC0193740283",
                              :text => "FM12344" ,
                              :error => true, 
                              :error_message => MessageProxy.access_denied, 
                              :sender => user,
                              :place => @province
        })
    end
    
    it "should have no error " do
      proxy = MessageProxy.new @options
      proxy.analyse_number
      proxy.params.should eq({
                              :sender_address => @options[:from],
                              :nuntium_token => @options[:guid],
                              :text => @options[:body] ,
                              :sender => @hc_user,
                              :place => @health_center
      })
      
    end   
  end

  describe "Generate error " do
    it "should not save any report when no error with sender not found" do
      options = { :sender => nil, 
                  :error => true ,
                  :to => "9087726", 
                  :sender_address => "9087726",
                  :text => "xxxx",
                  :error_message => MessageProxy.unknown_user      
      }
      proxy = MessageProxy.new({})
     
      #proxy.stub!(:parameterize).and_return(options)
     
      md0       = Report.count
      referral   = Referral::Report.count
          
      message = proxy.generate_error options
      
      Report.count.should eq(md0)
      Referral::Report.count.should eq(referral)
      
      message.should eq([ { :from => MessageProxy.app_name, 
                            :body => MessageProxy.unknown_user, 
                            :to => options[:sender_address] } ] )
    end
        
    
    it "should save error report to MD0 for user from MD0 app" do
      
      options = { :sender => @hc_user_disable_both, 
                  :place  => @hc_user_disable_both.place,
                  :error  => true ,
                  :to     => "9087726", 
                  :sender_address => "9087726",
                  :text => "",
                  :error_message => MessageProxy.access_denied      
      }
      proxy = MessageProxy.new({})
     
      #proxy.stub!(:parameterize).and_return(options)
     
      md0       = Report.count
      message = proxy.generate_error options    
      
      Report.count.should eq(md0+1)
      message.should eq([ { :from => MessageProxy.app_name, 
                            :body => MessageProxy.access_denied, 
                            :to => options[:sender_address] } ] )
    end
    
    it "should save error report to Referral report only if user from Referral app" do
      
      options = { :sender => @hc_user_disable_referral, 
                  :place  => @hc_user_disable_referral.place,
                  :error  => true ,
                  :to     => "9087726", 
                  :sender_address => "9087726",
                  :text => "",
                  :error_message => MessageProxy.access_denied      
      }
      proxy = MessageProxy.new({})
     
      #proxy.stub!(:parameterize).and_return(options)
     
      count     = Referral::Report.count
      message   = proxy.generate_error options
      
      
      
      Referral::Report.count.should eq(count+1)
      message.should eq([ { :from => MessageProxy.app_name, 
                            :body => MessageProxy.access_denied, 
                            :to => options[:sender_address] } ] )
    end
  end
  
  
  describe "guess_type message for user from both ref and md0 app" do
    before(:each) do
       @format_message_clinic = Referral::MessageFormat.create :format => "{phone_number}.{code_number}.{book_number}", :sector => Referral::MessageFormat::TYPE_CLINIC
       @format_message_hc = Referral::MessageFormat.create :format => "{phone_number}.{code_number}.{book_number}", :sector => Referral::MessageFormat::TYPE_HC
    end
    
    it "should return referral clinic report for od user" do
      options = { :text => "097123456.xxx", 
                  :sender_address => @od_user_both.phone_number, 
                  :sender => @od_user_both, 
                  :place => @od_user_both.place 
      }
      proxy = MessageProxy.new({})
      #proxy.stub!(:parameterize).and_return(options)
      report = proxy.guess_type options
      report.should be_kind_of Referral::ClinicReport
    end
    
    it "should return md0 report for user from village" do
      options = { :text => "097123456.001.002", 
                  :sender_address => @vmw_user.phone_number,
                  :sender => @vmw_user, 
                  :place => @vmw_user.place
      }
      proxy = MessageProxy.new({})
      #proxy.stub!(:parameterize).and_return(options)
      report = proxy.guess_type options
      report.should be_kind_of VMWReport
    end
    
    describe "report from both app" do
      it "should return referral hc report since Referral::HCParse parse the message successfully" do
        options = { :text => "097123456.001.002", 
                    :sender_address => @hc_user.phone_number, 
                    :sender => @hc_user, 
                    :place => @hc_user.place
        }
        proxy = MessageProxy.new({})
        #proxy.stub!(:parameterize).and_return(options)
        report = proxy.guess_type options
        report.should be_kind_of Referral::HCReport
      end
      
      it "should return md0 hc report since parse the md0 format message successfully" do
        options = { :text => "V28F3.", # malaria_type(F|V|M)Age(\d{3})Sex(F|M)day(0|28|30)VillageCode(\d{8}|\d{10}
                    :sender_address => @hc_user.phone_number, 
                    :sender => @hc_user, 
                    :place => @hc_user.place
        }
        proxy = MessageProxy.new({})
        #proxy.stub!(:parameterize).and_return(options)
        report = proxy.guess_type options
        report.should be_kind_of HealthCenterReport
      end
      
      it "should return md0 report " do
        options = { :text => "V12", # malaria_type(F|V|M)Age(\d{3})Sex(F|M)day(0|28|30)VillageCode(\d{8}|\d{10}
                    :sender_address => @hc_user.phone_number, 
                    :sender => @hc_user, 
                    :place => @hc_user.place
        }
        proxy = MessageProxy.new({})
        #proxy.stub!(:parameterize).and_return(options)
        report = proxy.guess_type options
        report.should be_kind_of HealthCenterReport
      end
      
      it "should return referral report since it can parse referral" do
        options = { :text => "098123456.fake.fake", # malaria_type(F|V|M)Age(\d{3})Sex(F|M)day(0|28|30)VillageCode(\d{8}|\d{10}
                    :sender_address => @hc_user.phone_number, 
                    :sender => @hc_user, 
                    :place => @hc_user.place
        }
        proxy = MessageProxy.new({})
        report = proxy.guess_type options
        report.should be_kind_of Referral::HCReport
      end
      
      it "should return md0 report since it can parse md0" do
        options = { :text => "Fxxx", # malaria_type(F|V|M)Age(\d{3})Sex(F|M)day(0|28|30)VillageCode(\d{8}|\d{10}
                    :sender_address => @hc_user.phone_number, 
                    :sender => @hc_user, 
                    :place => @hc_user.place
        }
        proxy = MessageProxy.new({})
        report = proxy.guess_type options
        report.should be_kind_of HealthCenterReport
      end
      
      it "should return md0 report since non of md0 and referral were able to pass" do
        options = { :text => "09123456", # malaria_type(F|V|M)Age(\d{3})Sex(F|M)day(0|28|30)VillageCode(\d{8}|\d{10}
                    :sender_address => @hc_user.phone_number, 
                    :sender => @hc_user, 
                    :place => @hc_user.place
        }
        proxy = MessageProxy.new({})
        report = proxy.guess_type options
        report.should be_kind_of HealthCenterReport
      end
      
      
    end
    
  end  
end