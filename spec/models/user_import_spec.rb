require 'spec_helper'

describe "UserImport" do
  let!(:province) { Province.make :code => '01' }
  let!(:od) { province.ods.make :code => '02' }
  let!(:health_center) { od.health_centers.make :code => '03' }

  let(:file) { File.join(File.dirname(File.dirname(__FILE__)),"import_data","users.csv") }

  describe "simulate" do
    let!(:users) { UserImporter.simulate file }

    it "should contain 3 users" do
      users.length.should eq(3)
    end

    it "should get the attributes from the csv" do
      users[0].should be_valid
      users[0].user_name.should eq('user1')
      users[0].email.should eq("dya1@yaho.com")
      users[0].phone_number.should eq("98764309")
      users[0].password.should eq("123456")
      users[0].intended_place_code.should eq("01")
      users[0].role.should eq("admin")
    end

    it "should change role to default when role is empty" do
      users[1].role.should eq("default")
    end

    it "should create invalid user when role is not valid" do
      users[2].should_not be_valid
    end
  end

  describe "import" do
    let!(:count) { UserImporter.import file }

    it "should return the created users count" do
      count.should eq(2)
    end

    it "creates users" do
      User.count.should eq(2)
    end

    it "creates users with attributes from csv" do
      user = User.first
      user.user_name.should eq('user1')
      user.email.should eq("dya1@yaho.com")
      user.phone_number.should eq("98764309")
      user.place.should eq(province)
      user.role.should eq("admin")
    end
  end
end
