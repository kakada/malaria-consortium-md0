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

      health_center = od.health_centers.create!({
          :name => "health_center",
          :name_kh => "health_center_kh",
          :code => "h10010"
        })

      @valid_attributes = {
        :name => "value for name",
        :name_kh => "value for name_kh",
        :code => "v10010",
        :parent_id => health_center.id,
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

    describe "hc_count_reports_since" do
      before(:each) do
        @hc1 = HealthCenter.make :code => "1"
        @hc2 = HealthCenter.make :code => "2"
        @hc3 = HealthCenter.make :code => "3"

        @village = Village.make :code => '11'

        @user = User.create! :place => @hc1, :phone_number => '1'

        @report_hc1 = Report.make :place => @hc1, :village => @village, :malaria_type => 'M', :sex => 'Male', :age => 23, :sender => @user
        @report_hc2 = Report.make :place => @hc1, :village => @village, :malaria_type => 'F', :sex => 'Male', :age => 23, :sender => @user, :created_at => 8.days.ago
        @report_hc3 = Report.make :place => @hc3, :village => @village, :malaria_type => 'F', :sex => 'Male', :age => 23, :sender => @user, :created_at => 8.days.ago
      end

      it "should count all od1 reports" do
        reports_count = @hc1.count_sent_reports_since 9.days.ago
        reports_count.should == 2
      end

      it "should count only the newest ones" do
        reports_count = @hc1.count_sent_reports_since 7.days.ago
        reports_count.should == 1
      end
    end

    it "returns the sub_place_class" do
      Country.national.sub_place_class.should == "Province"
    end

    it "returns Village for Village.sub_place_class" do
      Place::Types.last.constantize.sub_place_class.should == Place::Types.last
    end
end
