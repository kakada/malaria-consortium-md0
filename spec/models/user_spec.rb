require 'spec_helper'

describe User do
  before(:each) do
    @valid_attributes = {
      :user_name => "value for user_name",
      :password => "value for password",
      :phone_number => "85512666555"
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@valid_attributes)
  end

  it "should have no blank phone_number" do
    user = User.new(@valid_attributes.merge(:phone_number=>""))
    user.save
    User.count.should == 0
  end
  
  it "should not allow in valid phone format" do
    attr = @valid_attributes.merge(:phone_number=>"85500011")
    count = User.count
    user = User.new(attr)
    user.save
    User.count.should eq count
  end

  it "should provide the correct parser" do
    parser = User.make(:in_health_center).report_parser
    parser.class.should == HCReportParser

    parser = User.make(:in_village).report_parser
    parser.class.should == VMWReportParser
  end
  
  
  describe "fetch place id" do
     before(:each) do
       @province = Province.make
       @od = @province.ods.make :code => "001122", :name => "Battambong", :abbr => "BTB"
       @health_center = @od.health_centers.make
       @village = @health_center.villages.make :code => '12345678'
       
       @valid = { :phone_number => "85512123456", 
                 :_od => @od.id, 
                 :_healthcenter => @health_center.id,
                 :_village => @village.id
                 }
     end
    
     it "should use od as place_id when role is facilitator" do
       user = User.new @valid.merge(:role => User::ROLE_REF_FACILITATOR)
       user.save
       user.place.class.should eq OD
     end
     
     it "should use healthcenter as place_id when role is healthcenter" do
       user = User.new @valid.merge(:role => User::ROLE_REF_HC)
       user.save
       user.place.class.should eq HealthCenter
     end
     
     it "should use village as place_id when role is clinic" do
       user = User.new @valid.merge(:role => User::ROLE_REF_PROVIDER)
       user.save
       user.place.class.should eq Village
     end
     
     
    
  end

  it "should create 2 users with valid attributes" do
    Province.create! :name => "Pro1", :code => "Pro1"
    Province.create! :name => "Pro1", :code => "Pro2"

    @attrib = {
        :user_name => ["foo","bar"],
        :email => ["foo@yahoo.com","bar@yahoo.com"],
        :password => ["123456", "234567"],
        :phone_number => ["855975553553", "855975425678"],
        :place_code => ["Pro1","Pro2"],
        :role => [User::Roles[0], User::Roles[1] ]
    }
    User.save_bulk(@attrib)
    User.count.should == 2
  end

  describe "can_report?" do
     it "should return false if user status inactive can not report" do
       user = User.make :status => User::STATUS_DEACTIVE
       user.can_report?.should eq false
     end
     
     it "should return false if user have no place can not report" do
       user = User.make :status => User::STATUS_ACTIVE
       user.can_report?.should eq false
     end
     
     it "should return false if user only from Mdo APP but report for clinic" do
       user = User.make :status => User::STATUS_ACTIVE, :apps => [User::APP_MDO], :place => OD.make
       user.can_report?.should eq false
     end
     
     it "should return false if user only from Referral APP but report from OD " do
       user = User.make :status => User::STATUS_ACTIVE, :apps => [User::APP_REFERAL], :place => OD.make
       user.can_report?.should eq false
     end
     
     it "should return true for user from md0+referral from village, healthcenter, od" do
       [ User.make(:status => User::STATUS_ACTIVE, :apps => [User::APP_REFERAL, User::APP_MDO], :place => HealthCenter.make),
         User.make(:status => User::STATUS_ACTIVE, :apps => [User::APP_MDO,User::APP_REFERAL],  :place => Village.make),
       ].each do |user|
          user.can_report?.should eq true
       end
     end
     
     it "should return true " do
       [ User.make(:status => User::STATUS_ACTIVE, :apps => [User::APP_REFERAL], :place => HealthCenter.make),
         User.make(:status => User::STATUS_ACTIVE, :apps => [User::APP_MDO], :place => HealthCenter.make),
         User.make(:status => User::STATUS_ACTIVE, :apps => [User::APP_MDO], :place => Village.make)
       ].each do |user|
       
       user.can_report?.should eq true
     end
         
       
     end
    
  end

  describe "intended place code" do
    it "should try to find place by code before saving if intended place code is not nil" do
      province1 = Province.create! :name => "Pro1", :code => "Pro1"
      user = User.new :user_name => 'foo', :email => 'fooaddress@foo.com', :password => '123456', :intended_place_code => "Pro1"
      user.save
      user.valid?.should be_true
      user.place.should == province1
    end

    it "should cause validation to fail if it doesn't belong to a place" do
      user = User.new :user_name => 'foo', :email => 'fooaddress@foo.com', :password => '123456', :intended_place_code => "Pro1"
      user.save
      user.valid?.should be_false
      user.errors[:intended_place_code].count.should == 1
    end

    it "should not change a user's place upon update if it's nil or empty" do
      province1 = Province.create! :name => "Pro1", :code => "Pro1"
      user = User.create! :user_name => 'foo', :email => 'fooaddress@foo.com', :password => '123456', :place_id => province1.id

      user.intended_place_code = ''
      user.save
      user.place_id.should == province1.id

      user.intended_place_code = nil
      user.save
      user.place_id.should == province1.id
    end
  end

  describe "email validations" do
    it "should not create users with invalid email address" do
      invalid_user = User.new :user_name => 'foo', :email => 'fooaddress', :password => '123456'
      invalid_user.valid?.should be_false
      invalid_user.errors.size.should == 1
      invalid_user.errors[:email].should_not == nil
    end

    it "should create users with valid email address" do
      valid_user = User.new :user_name => 'foo', :email => 'fooaddress@foo.com', :password => '123456'
      valid_user.valid?.should be_true
      valid_user.errors.size.should == 0
    end

    it "should be unique" do
      valid_user = User.create! :user_name => 'foo', :password => '123456', :phone_number => '85512123567', :email => "foo@foo.com"
      invalid_user = User.new :user_name => 'foo2', :password => '123456', :phone_number  => '85597123568', :email => "foo@foo.com"
      invalid_user.valid?.should be_false
    end
  end

  describe "username validations" do
    it "should be unique" do
      valid_user = User.create! :user_name => 'foo', :password => '123456', :phone_number => '85512123567'
      invalid_user = User.new   :user_name => 'foo', :password => '123456', :phone_number => '85597123568'
      invalid_user.valid?.should be_false
    end
    
    it "should accept duplicate empty user" do
      valid_user = User.create! :user_name => '', :password => '123456', :phone_number => '85512123567'
      user = User.new   :user_name => '', :password => '123456', :phone_number => '85597123568'
      user.valid?.should be_true
    end
    
  end

  describe "phone number validations" do
    it "should not create users with invalid phone number" do
      expect {
        invalid_user = User.new :user_name => 'foo', :password => '123456', :phone_number => '1239123-1392132'
        invalid_user.save 
      }.to change{User.count}.by(0)
      
    end

    it "should create users with valid phone number" do
      valid_user = User.new :user_name => 'foo', :password => '123456', :phone_number => '85588123567'
      valid_user.valid?.should be_true
    end

    it "should be unique" do
      valid_user = User.create! :user_name => 'foo', :password => '123456', :phone_number => '85570123567'
      invalid_user = User.new :user_name => 'foo2', :password => '123456',  :phone_number => '85570123567'
      invalid_user.valid?.should be_false
    end
  end

  describe "role validations" do
    it "should be in the list of roles" do
      valid_user = User.create! :user_name => 'foo',   :password => '123456',  :phone_number => '85570123561', :role => 'admin'
      valid_user2 = User.create! :user_name => 'foo2', :password => '1234562', :phone_number => '85570123562', :role => 'national'
        
      invalid_user = User.new :user_name => 'foo23', :password => '12345623', :phone_number => '85570123500', :role => 'foo'
      invalid_user.valid?.should be_false
    end
  end

  describe "either has a phone number or a username AND a password AND an email" do
    it "should be valid if it only has a phone number" do
      valid_user = User.new :phone_number => '85515123456'
      valid_user.valid?.should be_true
    end

    it "should be valid if it has username, password and email" do
      valid_user = User.new :user_name => "foo", :password => "123456", :email => "a@a.com"
      valid_user.valid?.should be_true
    end

    it "should be invalid if it has no phone and no username" do
      valid_user = User.new :user_name => "", :password => "123456", :email => "a@a.com"
      valid_user.valid?.should be_false
    end

    it "should be invalid if it has no phone and no password" do
      valid_user = User.new :user_name => "foo", :password => "", :email => "a@a.com"
      valid_user.valid?.should be_false
    end

    it "should be invalid if it has no phone and no email" do
      valid_user = User.new :user_name => "foo", :password => "foo", :email => ""
      valid_user.valid?.should be_false
    end
  end

  describe "setting nuntium custom attributes" do
    before(:each) do
      @nuntium_api.should_not_receive(:set_custom_attributes).with('sms://', anything)
    end

    it "should set custom attributes for new user in village" do
      @nuntium_api.should_receive(:set_custom_attributes).with('sms://85516000111', {:application => 'MD0-Staging'})
      User.create! :phone_number => '85516000111', :place => Village.make
    end

    it "should not set custom attributes for user in province" do
      @nuntium_api.should_not_receive(:set_custom_attributes)
      User.create! :phone_number => '85516000112', :place => Province.make
    end

    it "should not set custom attributes if it has no phone" do
      @nuntium_api.should_not_receive(:set_custom_attributes)
      User.create! :user_name => 'user', :password => '123456', :email => 'user@email.com'
    end

    it "should unset custom attributes if moved to province" do
      u = User.create! :phone_number => '85516000113', :place => Village.make
      @nuntium_api.should_receive(:set_custom_attributes).with('sms://85516000113', {:application => nil})
      u.place = Province.make
      u.save!
    end

    it "should clear the custom attribute when the phone is unset" do
      u = User.create! :user_name => 'user', :password => '123456', :email => 'user@email.com',
                       :phone_number => '85516000114', :place => Village.make
      @nuntium_api.should_receive(:set_custom_attributes).with('sms://85516000114', {:application => nil})
      u.phone_number = nil
      u.save!
    end

    it "should clear custom attributes but not set new ones when moving to province with new number" do
      u = User.create! :phone_number => '85516000115', :place => Village.make
      @nuntium_api.should_receive(:set_custom_attributes).with('sms://85516000115', {:application => nil})
      @nuntium_api.should_not_receive(:set_custom_attributes).with('sms://85516000456', anything)
      u.phone_number = '85516000456'
      u.place = Province.make
      u.save!
    end

    it "should not set or clear custom attributes for new or updated province user" do
      @nuntium_api.should_not_receive(:set_custom_attributes)
      u = User.create! :phone_number => '85516000116', :place => Province.make
      u.phone_number = '85516000119'
      u.save!
    end

    it "should delete custom attributes when a user is deleted" do
      @nuntium_api.should_receive(:set_custom_attributes)
      user = User.create! :phone_number => '85516000111', :place => Village.make

      @nuntium_api.should_receive(:set_custom_attributes).with('sms://85516000111', {:application => nil})
      user.destroy
    end
  end

  describe "search for user" do
    before(:each) do
       @village = Village.make
       
       @v1 = User.make :user_name => "user1" , :phone_number => "85597888120", :place =>@village
       @h1 = User.make :user_name => "user2" , :phone_number => "85597888121", :place =>@village.health_center
       @h2 = User.make :user_name => "dara", :phone_number => "85597888122", :place =>@village.health_center
       
       @d1 = User.make :user_name => "bopha",  :phone_number => "85597888123", :place =>@village.od

       @p1 = User.make :user_name => "ratha", :phone_number => "85597888124", :place =>@village.province
       @p2 = User.make :user_name => "vibol" , :phone_number => "85597888125", :place =>@village.province
       @p3 = User.make :user_name => "rathana" , :phone_number => "85597888126", :place =>@village.province
       
       @d2 = User.make :user_name => "thuna" , :phone_number => "85597888127", :place =>@village.od
    end

    it "should return all users when no parameter provided" do
      users = User.search :type => "", :query => ""
      users.count.should == 8
    end

    it "should return all provincial users" do
      users = User.search :type => "Province"
      users.should =~ [@p1, @p2, @p3]
    end

    it "should return all village users" do
      users = User.search :type => "Village"
      users.should =~[@v1]
    end

    it "should return all health center users" do
      users = User.search :type => "HealthCenter"
      users.should =~ [@h2, @h1]
    end

    it "should return 2 users who have user_name start with 'user' " do
       users = User.search :type=>"", :query => "user"
       users.count.should == 2

       [users[0].user_name, users[1].user_name].should =~ ["user1", "user2"]
    end

    it "should return 1 user who has user_name start with 'user' and come from a village " do
      users = User.search :type=> "Village", :query => "user"
      users.count.should == 1
      users[0].user_name.should == "user1"
      users[0].place_class.should == "Village"
    end

    it "should return empty list when user not found" do
      users = User.search :type => "Village", :query => "not available value"
      users.count.should == 0
    end
  end

  describe "count user with place" do
    before(:each) do
       @village = Village.make
       @other = Village.make

       @v1 = User.make :user_name => "vuser1" , :phone_number => "85597888120" , :place => @village
       @v2 = User.make :user_name => "vuser2", :phone_number  =>  "85597366346", :place => @village, :status => false
       @v3 = User.make :user_name => "vuser3", :phone_number  =>  "85597366345", :place => @village


       @v4 = User.make :user_name => "vuser4", :phone_number => "85597124537", :place => @other
       

       @h1 = User.make :user_name => "huser" , :phone_number => "85597888121", :place => @village.health_center
       @h2 = User.make :user_name => "dara", :phone_number   => "85597888122", :place => @village.health_center

       @d1 = User.make :user_name => "bopha",  :phone_number => "85597888123", :place => @village.od, :status => false
       @d2 = User.make :user_name => "thuna" , :phone_number => "85597888127", :place => @village.od

      
       @p1 = User.make :user_name => "ratha", :phone_number  => "85597888124", :place => @village.province
       @p2 = User.make :user_name => "vibol" , :phone_number => "85597888125", :place => @village.province, :status => false

       @p3 = User.make :user_name => "rathana" , :phone_number => "85597888126", :place => @village.province
       
       @p4 = User.make :user_name => "vicheka" , :phone_number => "85597880000", :place => @other.province

    end

    it "should return all user with status iqual true" do
      users = User.count_user
      
      users[0][:place].should eq Province
      users[0][:count].should eq 3

      users[1][:place].should eq OD
      users[1][:count].should eq 1

      users[2][:place].should eq HealthCenter
      users[2][:count].should eq 2

      users[3][:place].should eq Village
      users[3][:count].should eq 3
    end

    

    it "should return all place class with it number of user in that place and users located in the place" do

      users = User.count_user @village.province

      users[0][:place].should eq Province
      users[0][:users].count.should eq 2
      
      users[0][:users][0].user_name.should eq "ratha"
      users[0][:users][1].user_name.should eq "rathana"

      users[1][:place].should eq OD
      users[1][:count].should eq 1


      users[2][:place].should eq HealthCenter
      users[2][:count].should eq 2

      users[3][:place].should eq Village
      users[3][:count].should eq 2    
    end

    it "should return only village users with status true" do
      users = User.count_user(@village)
      users[0][:place].should eq Village
      users[0][:users].count.should eq 2

      users[0][:users][0].user_name.should  == "vuser1"
      users[0][:users][1].user_name.should  == "vuser3"
     
    end
  end

  describe "user_from_place" do
    before(:each) do
       @village = Village.make

       @v1 = User.make :user_name => "vuser1" , :phone_number => "85597888120", :place => @village
       @v2 = User.make :user_name => "vuser2", :phone_number => "85597366346", :place => @village, :status => false
       @v3 = User.make :user_name => "vuser3", :phone_number => "85597356346", :place => @village

       @h1 = User.make :user_name => "huser" , :phone_number => "85597888121", :place => @village.health_center
       @h2 = User.make :user_name => "dara", :phone_number => "85597888122", :place => @village.health_center

       @d1 = User.make :user_name => "bopha",  :phone_number => "85597888123", :place => @village.od, :status => false
       @d2 = User.make :user_name => "thuna" , :phone_number => "85597888127", :place => @village.od

       @p1 = User.make :user_name => "ratha", :phone_number => "85597888124", :place => @village.province
       @p2 = User.make :user_name => "vibol" , :phone_number => "85597888125", :place => @village.province, :status => false
       @p3 = User.make :user_name => "rathana" , :phone_number => "85597888126", :place => @village.province
       @p4 = User.make :user_name => "vicheka" , :phone_number => "85597880000", :place => @village.province, :status => false
    end

    it "should return all activated village users" do
      users = User.user_from_place( 0 , ["Village"])
      users.count.should eq 2
      [users[0].user_name, users[1].user_name].should =~ ["vuser1", "vuser3"]
    end

    it "should return all activated health center user" do
      users = User.user_from_place( nil , ["HealthCenter"])
      users.count.should eq 2
      [users[0].user_name, users[1].user_name].should =~ ["huser", "dara"]
    end

    it "should return all activated od user" do
      users = User.user_from_place( nil , ["OD"])
      users.count.should eq 1
      users[0].user_name.should eq "thuna"
    end

    it "should return all activated province user" do
      users = User.user_from_place( nil , ["Province"])
      users.count.should eq 2
      [users[0].user_name, users[1].user_name].should =~ ["rathana", "ratha"]
    end

    it "should return all activated province and village user" do
      users = User.user_from_place( nil , ["Province","Village"])
      users.count.should eq 4
      [users[0].user_name, users[1].user_name, users[2].user_name, users[3].user_name ].should =~ ["vuser1", "vuser3", "rathana", "ratha"]
    end

    it "should return only activated village user" do
      users = User.user_from_place( @village.od.id , ["Province","Village"])
      users.count.should eq 2
      [users[0].user_name, users[1].user_name].should =~ ["vuser1", "vuser3"]
    end

    it "should return empty array" do
      users = User.user_from_place( nil , [])
      users.count.should eq 0
    end
    
  end

  describe "update params" do
    before(:each) do
      @village = Village.make
      @healthcenter = @village.health_center
      @od = @village.od
      @province = @village.province

      @user = User.make :place => @village

      @attributes = {
        :user_name => "valide" ,
        :email => "valid@yahoo.com" ,
        :password => "123456" ,
        :password_confirmation => "123456",
        :phone_number => "855975553553" ,
        :intended_place_code => @od.description
      }
      
    end

    it "should save the user " do
      state = @user.update_params @attributes
      state.should be_true
      user = User.find(@user.id)
      
      user.user_name.should == @attributes[:user_name]
      user.email.should == @attributes[:email]
      user.phone_number.should == @attributes[:phone_number]
      user.place_class.should == "OD"

    end
    
    
    describe ".apps refered in [APP_MDO, APP_REFERAL]" do
       
       it "should set_app_mask for both" do
          user = User.new :apps => [User::APP_REFERAL, User::APP_MDO]
          user.apps_mask.should eq 3
       end
       it "should set_app_mask for second element" do
          user = User.new :apps => [User::APP_MDO]
          user.apps_mask.should eq 1
       end
       
       it "should set_app_mask for second element" do
          user = User.new :apps => [User::APP_REFERAL]
          user.apps_mask.should eq 2
       end
    end
    
    describe "#selected_app" do
      it "should use apps_mask and return User apps [APP_MDO, APP_REFERAL] " do
        User.selected_apps(3).should eq [User::APP_MDO, User::APP_REFERAL]
      end
      it "should use apps_mask and return User apps [APP_MDO, APP_REFERAL] " do
        User.selected_apps(2).should eq [User::APP_REFERAL]
      end
      
      it "should use apps_mask and return User apps [APP_MDO, APP_REFERAL] " do
        User.selected_apps(1).should eq [User::APP_MDO]
      end
    end
    
    
    describe "is_from_both?" do
      it "should return true for user from both app" do
        user = User.new :apps =>[User::APP_MDO, User::APP_REFERAL]
        user.is_from_both?.should eq true
      end
      
      it "should return false if user is not from both" do
        [ User.new(:apps =>[User::APP_MDO]),
         User.new(:apps =>[User::APP_REFERAL])
         ].each do |user|
           user.is_from_both?.should eq false
         end
      end
    end
    
    describe "is_form_md0?" do
      it "should return true if user from md0" do
        [ User.new(:apps =>[User::APP_MDO, User::APP_REFERAL]),
          User.new(:apps =>[User::APP_MDO])
        ].each do |user|
             user.is_from_md0?.should eq true
        end
      end
      
      it "should return false if user not from md0" do
         user = User.new(:apps =>[User::APP_REFERAL])
         user.is_from_md0?.should eq false
      end
    end
    
    describe "is_form_referral?" do
      it "should return true if user from referral" do
        [ User.new(:apps =>[User::APP_MDO, User::APP_REFERAL]),
          User.new(:apps =>[User::APP_REFERAL])
        ].each do |user|
          user.is_from_referral?.should eq true
        end
      end
      
      it "should return false if user not from referral" do
         user = User.new(:apps =>[User::APP_MDO])
         user.is_from_referral?.should eq false
      end
      
    end
        
  end
end
