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

    @valid_message = {:from => "sms://8558190", :body => "F123M012345678"}
    @valid_vmw_message = {:from => "sms://8558191", :body => "F123M0."}
  end

  describe "create report" do
    before(:each) do
      @valid = {
        :malaria_type => "M" ,
        :sex => "Female",
        :age => 12,
        :sender_id => @hc_user,
        :place_id => @hc_user.place.id,
        :day => 0
      }
    end

    describe "validate malaria type" do
      it "should create report with malaria type 'n/N'" do
        report = Report.make :malaria_type => "n"
        report = Report.create! @valid
        report.should be_valid

        report = Report.make :malaria_type => "N"
        report = Report.create! @valid
        report.should be_valid
      end

      it "should create report with malaria type 'f/F'" do
        report = Report.make :malaria_type => "f"
        report = Report.create! @valid
        report.should be_valid

        report = Report.make :malaria_type => "F"
        report = Report.create! @valid
        report.should be_valid
      end

      it "should create report with malaria type 'm/M'" do
        report = Report.make :malaria_type => "m"
        report = Report.create! @valid
        report.should be_valid

        report = Report.make :malaria_type => "M"
        report = Report.create! @valid
        report.should be_valid
      end

      it "should create report with malaria type 'v/V'" do
        report = Report.make :malaria_type => "v"
        report = Report.create! @valid
        report.should be_valid

        report = Report.make :malaria_type => "V"
        report = Report.create! @valid
        report.should be_valid
      end
    end

    describe "valid attribute" do
      it "should create a new report" do
          report = HealthCenterReport.create! @valid
          report.should be_valid
      end
      describe "build hierachy" do
          it "should build the correct hierachy with health center " do
             report = HealthCenterReport.create! @valid
             report.village.should be_nil
             report.health_center.should eq @health_center
             report.od.should eq @health_center.od
             report.province.should eq @health_center.province
          end

          it "should build the correct hierachy with village" do
             report = HealthCenterReport.create! @valid.merge(:village_id => @village.id)
             report.village.should eq @village
             report.health_center.should eq @village.health_center
             report.od.should eq @village.od
             report.province.should eq @village.province
          end
        end
    end

    describe "invalid attribute" do
      describe " malaria type" do
        it "should require malaria_type in case no error" do
          report = Report.new @valid.merge({:malaria_type => nil })
          report.should_not be_valid
        end

        it "should require the correct type of malaria" do
          ['A','B','c','d'].each do |elm|
            report = Report.new @valid.merge({:malaria_type => elm })
            report.should_not be_valid
          end
        end

        it "should require sex in case no error" do
          report = Report.new @valid.merge :sex => nil
          report.should_not be_valid
        end

        it "should require the correct type of sex: Female or Male " do
           ["M","F","female","male", "female"].each do |elm|
             report = Report.new @valid.merge :sex => elm
             report.should_not be_valid
           end
        end



        it "should require age " do
          report = Report.new @valid.merge :age =>nil
          report.should_not be_valid
        end

        it "should be a valid number " do
          report = Report.new @valid.merge :age => -1
          report.should_not be_valid
        end

        it "should require sender id" do
          report = Report.new @valid.merge :sender_id => nil
          report.should_not be_valid
        end
      end
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
  
  describe "generate_alert" do
    it "should invoke error_alert when report error" do
      report = Report.make :error => true
      report.should_receive(:error_alert).once
      report.generate_alerts
    end
    
    it "should invoke valid_alerts when no error for report" do
      report = Report.make :error => false
      report.should_receive(:valid_alerts).once
      report.generate_alerts
    end
  end
  
end