require 'spec_helper'

describe Place do
  before(:each) do
      province = Place.create!({
             :name => "province",
             :name_kh => "province_kh",
             :code => "p10010",
             :place_type => Place::Province
             })

      od = Place.create!({
            :name=>"districtA",
            :name_kh => "district_khmer",
            :code => "d10010",
            :parent_id => province.id,
            :place_type => Place::OD
        })
        
      health_center = Place.create!({
          :name => "health_center",
          :name_kh => "health_center_kh",
          :code => "h10010",
          :parent_id => od.id,
          :place_type => Place::HealthCenter
        })

      @valid_attributes = {
        :name => "value for name",
        :name_kh => "value for name_kh",
        :code => "v10010",
        :parent_id => health_center.id,
        :place_type => Place::Village
      }
      
    end
    describe "Create new instance" do
      it "should create a new instance given valid attributes" do
        village = Place.create!(@valid_attributes)
        village.should_not be_nil
        Place.villages.count.should == 1
      end
    end
    describe "No duplicate code" do
      it "should not create a duplicated village with duplicate code" do
        village = Place.new(@valid_attributes)
        village.save
      
        invalid = @valid_attributes.merge :name=>"othervillage" ,:name_kh => "othervillage_kh"
        village = Place.new(invalid)
        village.save

        Place.villages.count.should == 1
      end
    end
end