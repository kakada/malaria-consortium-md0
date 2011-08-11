require 'spec_helper'

describe Report do
  before(:each) do
    @province = Province.make
    @od = @province.ods.make
    @health_center = @od.health_centers.make
    @village = @health_center.villages.make :code => '12345678'
    @health_center.villages.make :code => '87654321'

    @hc_user = @health_center.users.make :phone_number => "8558190"
    @vmw_user = @village.users.make :phone_number => "8558191"
    @od_user1 = @od.users.make :phone_number => "8558192"
    @od_user2 = @od.users.make :phone_number => "8558193"

    @valid_message = {:from => "sms://8558190", :body => "F123M12345678"}
    @valid_vmw_message = {:from => "sms://8558191", :body => "F123M."}
  end

  


  describe "invalid message" do
    def assert_response_error expected_response, orig_msg
      response = Report.process(orig_msg)

      response.is_a?(Array).should == true
      response.size.should == 1

      response[0][:to].should == orig_msg[:from]
      response[0][:body].should == expected_response
      response[0][:from].should == Report.from_app

      reports = Report.all
      reports.count.should eq(1)
      report = reports.first
      report.error.should be_true
    end

    it "should return unknown user before any other error" do
      assert_response_error Report.unknown_user(""), :from => "sms://31783123", :body => ""
    end

    it "should return error when user can't report" do
      user = User.make :phone_number => "1"
      User.should_receive(:find_by_phone_number).with("sms://1").and_return(user)
      user.should_receive(:can_report?).and_return(false)

      message = @valid_message.clone
      message[:from] = "sms://1"

      assert_response_error Report.user_should_belong_to_hc_or_village, message
    end
  end

  describe "precess message" do
    before(:each) do
      @village = Village.make :code => "1234567890"

      @v1 = User.make :user_name => "vuser1" , :phone_number => "85560001", :place => @village
      @v2 = User.make :user_name => "vuser2", :phone_number => "85560002", :place => @village, :status => false
      @v3 = User.make :user_name => "vuser3", :phone_number => "85560003", :place => @village

      @h1 = User.make :user_name => "huser" , :phone_number => "855970001", :place => @village.health_center
      @h2 = User.make :user_name => "dara", :phone_number => "855970002", :place => @village.health_center
      @h3 = User.make :user_name => "daroy", :phone_number => "855970003", :place => @village.health_center, :status =>  false

      @d1 = User.make :user_name => "bopha",  :phone_number => "855980001", :place => @village.od, :status => false
      @d2 = User.make :user_name => "thuna" , :phone_number => "855980002", :place => @village.od

      @p1 = User.make :user_name => "ratha", :phone_number => "855990001", :place => @village.province
      @p2 = User.make :user_name => "vibol" , :phone_number => "855990002", :place => @village.province, :status => false
      @p3 = User.make :user_name => "rathana" , :phone_number => "855990003", :place => @village.province
      @p4 = User.make :user_name => "vicheka" , :phone_number => "855990004", :place => @village.province, :status => false

      @message = {:from => "sms://8558190", :body => "F123M1234567890"}
      
    end

    it "should denied access if with desactived health center user (status is false)" do
       response = Report.process @message.merge(:from => "sms://855970003" )
       response[0][:body].should eq Report.user_should_belong_to_hc_or_village  
    end

    it "should denied access if with desactived village center user (status is false)" do
       response = Report.process @message.merge(:from => "sms://85560002" )
       response[0][:body].should eq Report.user_should_belong_to_hc_or_village
    end


    it "should denied access if user not from village or health center" do
      responses = Report.process @message.merge(:from => "sms://855990001" )
      responses[0][:body].should eq Report.user_should_belong_to_hc_or_village
    end

    

    it "should denied access if status is false" do
      responses = Report.process @message.merge(:from => "sms://855970002" )
      responses.size.should eq 5
      responses.should =~ [ {:to=>"sms://855970001", :body=>"", :from=>"malariad0://system" },
                            {:to=>"sms://855970002", :body=>"", :from=>"malariad0://system" },
                            {:to=>"sms://855980002", :body=>"", :from=>"malariad0://system" },
                            {:to=>"sms://855990001", :body=>"", :from=>"malariad0://system" },
                            {:to=>"sms://855990003", :body=>"", :from=>"malariad0://system" } ]
      
    end




    
    
    

  end






  describe "valid message" do
    it "should return human readable message with details" do
      User.should_receive(:find_by_phone_number).with("sms://8558190").and_return(@hc_user)

      report = setup_successful_parser "successful report"
      report.stub(:human_readable => 'xxx')
      report.stub!(:generate_alerts).and_return([{:body => "alert1", :to => "sms://1"},
                                                 {:body => "alert2", :to => "sms://2"},
                                                 {:body => "alert3", :to => "sms://3"}])

      response = Report.process @valid_message

      @valid_message = {:from => "sms://8558190", :body => "f123M12345678"}

      report.malaria_type.should == 'F'
      report.age.should == 123
      report.sex.should == 'Male'
      report.village.should == @village
      report.sender.should == @hc_user
      report.place.should == @health_center

      response.should =~ [
        {:to => @hc_user.phone_number.with_sms_protocol, :body => report.human_readable, :from => Report.from_app},
        {:body => "alert1", :to => "sms://1", :from => Report.from_app},
        {:body => "alert2", :to => "sms://2", :from => Report.from_app},
        {:body => "alert3", :to => "sms://3", :from => Report.from_app}
      ]

      response.each do |reply|
        assert_nuntium_fields reply
      end
    end

    it "should return an array of hashes even if there's only one hash" do
      User.should_receive(:find_by_phone_number).with("sms://8558190").and_return(@hc_user)
      report = setup_successful_parser "successful report"
      report.stub!(:generate_alerts).and_return []

      response = Report.process @valid_message
      response.is_a?(Array).should == true
      response.size.should == 1
    end

    it "should upcase malaria type" do
      report = Report.new :malaria_type => 'f', :age => 123, :sex => 'Male',
        :village_id => @village.id, :sender_id => @hc_user.id, :place_id => @health_center.id
      report.save!
      report.malaria_type.should == 'F'
    end

    it "should notify hc when vmw reports" do
      Setting[:single_village_case_template] = 'A {test_result}-{malaria_type} case ({sex}, {age}) has been detected in {village} by the VMW {contact_number}'
      response = Report.process @valid_vmw_message
      hc_msg = response.select {|x| x[:to] == @hc_user.phone_number.with_sms_protocol }
      hc_msg.should have(1).items
      hc_msg[0][:body].should == "A Pf-F case (Male, 123) has been detected in #{@village.name} by the VMW #{@vmw_user.phone_number}"
    end

    def assert_nuntium_fields data
      [:from,:body,:to].should =~ data.keys
    end

    def setup_successful_parser success_message
      parser = {}
      @hc_user.should_receive(:report_parser).and_return(parser)
      parser.should_receive(:parse).with(@valid_message[:body]).and_return(parser)
      parser.should_receive(:errors?).and_return(false)

      report = Report.new :malaria_type => 'F', :age => 123, :sex => 'Male',
        :village_id => @village.id, :sender_id => @hc_user.id, :place_id => @health_center.id

      report.stub!(:human_readable).and_return success_message

      parser.should_receive(:report).and_return(report)
      report
    end
  end

  it "returns last errors per sender per day" do
    user1 = User.make
    user2 = User.make

    Report.make :error => true, :sender => user1, :created_at => '2011-06-20 10:00:00'
    Report.make :sender => user1, :created_at => '2011-06-20 12:00:00'

    Report.make :error => true, :sender => user2, :created_at => '2011-06-20 10:00:00'
    last1 = Report.make :error => true, :sender => user2, :created_at => '2011-06-20 12:00:00'
    last2 = Report.make :error => true, :sender => user2, :created_at => '2011-06-21 12:00:00'

    reports = Report.last_error_per_sender_per_day
    reports.all.should =~ [last2, last1]
  end

  it "returns duplicated reports per sender per day" do
    user1 = User.make
    user2 = User.make

    r1 = Report.make :text => 'foo', :sender => user1, :created_at => '2011-06-20 10:00:00'
    r2 = Report.make :text => 'foo', :sender => user1, :created_at => '2011-06-20 12:00:00'
    r3 = Report.make :text => 'foo', :sender => user1, :created_at => '2011-06-20 13:00:00'

    Report.make :text => 'bar', :sender => user1, :created_at => '2011-06-20 14:00:00'

    r4 = Report.make :text => 'baz', :sender => user2, :created_at => '2011-06-20 15:00:00'
    r5 = Report.make :text => 'baz', :sender => user2, :created_at => '2011-06-20 16:00:00'

    Report.make :text => 'foo', :sender => user2, :created_at => '2011-06-20 16:00:00'

    Report.make :text => 'coco', :sender => user1, :created_at => '2011-06-21 15:00:00'
    Report.make :text => 'coco', :sender => user1, :created_at => '2011-06-22 16:00:00'

    reports = Report.duplicated_per_sender_per_day
    reports.all.should =~ [r5, r4, r3, r2, r1]
  end
end
