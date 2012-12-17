require "spec_helper"
describe MessageProxy do
  before(:each) do
    @province = Province.make
    @od = @province.ods.make
    @health_center = @od.health_centers.make
    @village = @health_center.villages.make :code => '12345678'
    @health_center.villages.make :code => '87654321'

    @hc_user = @health_center.users.make :phone_number => "8558190"
    @hc_user_disable = @health_center.users.make :phone_number => "8558199", :status => false
    @vmw_user = @village.users.make :phone_number => "8558191"
    @od_user1 = @od.users.make :phone_number => "8558192"
    @od_user2 = @od.users.make :phone_number => "8558193"

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
    it "should save report to MD0 and Referal when no sender was found" do
      options = { :sender => nil, 
                  :error => true ,
                  :to => "9087726", 
                  :sender_address => "9087726",
                  :text => "xxxx",
                  :error_message => MessageProxy.unknown_user      
      }
      proxy = MessageProxy.new({})
     
      proxy.stub!(:parameterize).and_return(options)
     
      md0       = Report.count
      referal   = Referal::Report.count
          
      message = proxy.generate_error
      
      Report.count.should eq(md0+1)
      Referal::Report.count.should eq(referal+1)
      message.should eq([ { :from => MessageProxy.app_name, 
                            :body => MessageProxy.unknown_user, 
                            :to => options[:sender_address] } ] )
    end
    
    it "should save report to MD0 for user from MD0 app" do
      
      options = { :sender => @hc_user_disable, 
                  :place  => @hc_user_disable.place,
                  :error  => true ,
                  :to     => "9087726", 
                  :sender_address => "9087726",
                  :text => "",
                  :error_message => MessageProxy.access_denied      
      }
      proxy = MessageProxy.new({})
     
      proxy.stub!(:parameterize).and_return(options)
     
      md0       = Report.count
      message = proxy.generate_error
      Report.count.should eq(md0+1)
      message.should eq([ { :from => MessageProxy.app_name, 
                            :body => MessageProxy.access_denied, 
                            :to => options[:sender_address] } ] )
    end
    
    it "should save report to Referal report for user from Referal app" do
      
      options = { :sender => @hc_user_disable, 
                  :place  => @hc_user_disable.place,
                  :error  => true ,
                  :to     => "9087726", 
                  :sender_address => "9087726",
                  :text => "",
                  :error_message => MessageProxy.access_denied      
      }
      proxy = MessageProxy.new({})
     
      proxy.stub!(:parameterize).and_return(options)
     
      md0       = Report.count
      message = proxy.generate_error
      Report.count.should eq(md0+1)
      message.should eq([ { :from => MessageProxy.app_name, 
                            :body => MessageProxy.access_denied, 
                            :to => options[:sender_address] } ] )
    end
    
    
    
    
  end
  
  
  
end