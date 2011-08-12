require 'spec_helper'

describe User do
  before(:each) do
    @valid_attributes = {
      :user_name => "value for user_name",
      :password => "value for password",
      :phone_number => "123456"
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

  it "should not be able to report unless she's in a health center or village" do
    [User.make, User.make(:in_od), User.make(:in_province)].each do |u|
      u.can_report?().should be_false
    end
  end

  it "should be able to report if she's in a health center or village" do
    [User.make(:in_village), User.make(:in_health_center)].each do |u|
      u.can_report?().should be_true
    end
  end

  it "should provide the correct parser" do
    parser = User.make(:in_health_center).report_parser
    parser.class.should == HCReportParser

    parser = User.make(:in_village).report_parser
    parser.class.should == VMWReportParser
  end

  it "should create 2 users with valid attributes" do
    Province.create! :name => "Pro1", :code => "Pro1"
    Province.create! :name => "Pro1", :code => "Pro2"

    @attrib = {
        :user_name => ["foo","bar"],
        :email => ["foo@yahoo.com","bar@yahoo.com"],
        :password => ["123456", "234567"],
        :phone_number => ["0975553553", "0975425678"],
        :place_code => ["Pro1","Pro2"],
        :role => [User::Roles[0], User::Roles[1] ]
    }
    User.save_bulk(@attrib)
    User.count.should == 2
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
      valid_user = User.create! :user_name => 'foo', :password => '123456', :phone_number => '123567', :email => "foo@foo.com"
      invalid_user = User.new :user_name => 'foo2', :password => '123456', :phone_number => '123568', :email => "foo@foo.com"
      invalid_user.valid?.should be_false
    end
  end

  describe "username validations" do
    it "should be unique" do
      valid_user = User.create! :user_name => 'foo', :password => '123456', :phone_number => '123567'
      invalid_user = User.new :user_name => 'foo', :password => '123456', :phone_number => '123568'
      invalid_user.valid?.should be_false
    end
  end

  describe "phone number validations" do
    it "should not create users with invalid phone number" do
      invalid_user = User.new :user_name => 'foo', :password => '123456', :phone_number => '1239123-1392132'
      invalid_user.valid?.should be_false
      invalid_user.errors.size.should == 1
      invalid_user.errors[:phone_number].should_not == nil
    end

    it "should create users with valid phone number" do
      valid_user = User.new :user_name => 'foo', :password => '123456', :phone_number => '123567'
      valid_user.valid?.should be_true
    end

    it "should be unique" do
      valid_user = User.create! :user_name => 'foo', :password => '123456', :phone_number => '123567'
      invalid_user = User.new :user_name => 'foo2', :password => '123456', :phone_number => '123567'
      invalid_user.valid?.should be_false
    end
  end

  describe "role validations" do
    it "should be in the list of roles" do
      valid_user = User.create! :user_name => 'foo', :password => '123456', :phone_number => '123567', :role => 'admin'
      valid_user2 = User.create! :user_name => 'foo2', :password => '1234562', :phone_number => '1235672', :role => 'national'

      invalid_user = User.new :user_name => 'foo23', :password => '12345623', :phone_number => '12356723', :role => 'foo'
      invalid_user.valid?.should be_false
    end
  end

  describe "either has a phone number or a username AND a password AND an email" do
    it "should be valid if it only has a phone number" do
      valid_user = User.new :phone_number => '123456'
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
      @nuntium_api.should_receive(:set_custom_attributes).with('sms://123', {:application => 'md0'})
      User.create! :phone_number => '123', :place => Village.make
    end

    it "should not set custom attributes for user in province" do
      @nuntium_api.should_not_receive(:set_custom_attributes)
      User.create! :phone_number => '123', :place => Province.make
    end

    it "should not set custom attributes if it has no phone" do
      @nuntium_api.should_not_receive(:set_custom_attributes)
      User.create! :user_name => 'user', :password => '123456', :email => 'user@email.com'
    end

    it "should unset custom attributes if moved to province" do
      u = User.create! :phone_number => '123', :place => Village.make
      @nuntium_api.should_receive(:set_custom_attributes).with('sms://123', {:application => nil})
      u.place = Province.make
      u.save!
    end

    it "should clear the custom attribute when the phone is unset" do
      u = User.create! :user_name => 'user', :password => '123456', :email => 'user@email.com', :phone_number => '123', :place => Village.make
      @nuntium_api.should_receive(:set_custom_attributes).with('sms://123', {:application => nil})
      u.phone_number = nil
      u.save!
    end

    it "should clear custom attributes but not set new ones when moving to province with new number" do
      u = User.create! :phone_number => '123', :place => Village.make
      @nuntium_api.should_receive(:set_custom_attributes).with('sms://123', {:application => nil})
      @nuntium_api.should_not_receive(:set_custom_attributes).with('sms://456', anything)
      u.phone_number = '456'
      u.place = Province.make
      u.save!
    end

    it "should not set or clear custom attributes for new or updated province user" do
      @nuntium_api.should_not_receive(:set_custom_attributes)
      u = User.create! :phone_number => '123', :place => Province.make
      u.phone_number = '456'
      u.save!
    end

    it "should delete custom attributes when a user is deleted" do
      @nuntium_api.should_receive(:set_custom_attributes)
      user = User.create! :phone_number => '123', :place => Village.make

      @nuntium_api.should_receive(:set_custom_attributes).with('sms://123', {:application => nil})
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

       @v1 = User.make :user_name => "vuser1" , :phone_number => "85597888120", :place => @village
       @v2 = User.make :user_name => "vuser2", :phone_number => "8559736634664", :place => @village, :status => false
       @v3 = User.make :user_name => "vuser3", :phone_number => "8559736634665", :place => @village
       

       @h1 = User.make :user_name => "huser" , :phone_number => "85597888121", :place => @village.health_center
       @h2 = User.make :user_name => "dara", :phone_number => "85597888122", :place => @village.health_center

       @d1 = User.make :user_name => "bopha",  :phone_number => "85597888123", :place => @village.od, :status => false
       @d2 = User.make :user_name => "thuna" , :phone_number => "85597888127", :place => @village.od

      
       @p1 = User.make :user_name => "ratha", :phone_number => "85597888124", :place => @village.province
       @p2 = User.make :user_name => "vibol" , :phone_number => "85597888125", :place => @village.province, :status => false
       @p3 = User.make :user_name => "rathana" , :phone_number => "85597888126", :place => @village.province
       @p4 = User.make :user_name => "vicheka" , :phone_number => "85597880000", :place => @village.province, :status => false
       

    end

    it "should return all user with status iqual true" do
      users = User.count_user
      
      users[0][:place].should eq Province
      users[0][:count].should eq 2

      users[1][:place].should eq OD
      users[1][:count].should eq 1

      users[2][:place].should eq HealthCenter
      users[2][:count].should eq 2

      users[3][:place].should eq Village
      users[3][:count].should eq 2
    end

    it "should return all place class with it number of user" do

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
       @v2 = User.make :user_name => "vuser2", :phone_number => "8559736634664", :place => @village, :status => false
       @v3 = User.make :user_name => "vuser3", :phone_number => "8559736634665", :place => @village

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
        :phone_number => "0975553553" ,
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

    
  end
end
