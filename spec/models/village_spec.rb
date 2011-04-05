require 'spec_helper'

describe Village do
  before(:each) do
    province = Province.create!({
           :name => "province",
           :name_kh => "province_kh",
           :code => "p10010"
           })

    district = District.create!({
          :name=>"districtA",
          :name_kh => "district_khmer",
          :code => "d10010",
          :province_id => province.id
      })
    health_center = HealthCenter.create!({
        :name => "health_center",
        :name_kh => "health_center_kh",
        :code => "h10010",
        :district_id => district.id
      })

    @valid_attributes = {
      :name => "value for name",
      :name_kh => "value for name_kh",
      :code => "v10010",
      :district_id => district.id,
      :health_center_id => health_center.id
    }
  end
  describe "Create new instance" do
    it "should create a new instance given valid attributes" do
      village = Village.create!(@valid_attributes)
      village.should_not be_nil
      Village.count.should == 1
    end
  end
  describe "No duplicate code" do
    it "should not create a duplicated village with duplicate code" do
      village = Village.new(@valid_attributes)
      village.save
      
      invalid = @valid_attributes.merge :name=>"othervillage" ,:name_kh => "othervillage_kh"
      village = Village.new(invalid)
      village.save

      Village.count.should == 1
    end
  end
end
