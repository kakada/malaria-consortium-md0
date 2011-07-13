require 'spec_helper'

describe Place do
  before(:each) do
      province = Province.create!({
             :name => "province",
             :name_kh => "province_kh",
             :code => "p10010",
             })

      od = province.ods.create!({
            :name=>"districtA",
            :name_kh => "district_khmer",
            :code => "d10010"
        })

      @health_center = od.health_centers.create!({
          :name => "health_center",
          :name_kh => "health_center_kh",
          :code => "h10010"
        })

      @valid_attributes = {
        :name => "value for name",
        :name_kh => "value for name_kh",
        :code => "v10010",
        :parent_id => @health_center.id,
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

      describe "Description" do
        it "should be like {place.code} {place.name} ({place type})" do
          village = Village.new @valid_attributes
          village.description.should == "v10010 value for name (Village)"
        end
      end
    end

    it "returns the sub_place_class" do
      Country.national.sub_place_class.should == "Province"
    end

    it "returns Village for Village.sub_place_class" do
      Place::Types.last.constantize.sub_place_class.should == Place::Types.last
    end
    
  
    describe "strip village code to 8 digit" do
      before(:each) do
        @v1 = Village.create! :name => "v1", :code => "10010090983", :parent_id => @health_center.id
        @v2 = Village.create! :name => "v2", :code => "10012345984", :parent_id => @health_center.id
        @v3 = Village.create! :name => "v3", :code => "10034330985", :parent_id => @health_center.id
      end

      it "should update village code to 8 digit" do
        Village.strip_code
        villages = Village.all
        villages[0].code.should == "10010090"
        villages[1].code.should == "10012345"
        villages[2].code.should == "10034330"
      end
    end
end
