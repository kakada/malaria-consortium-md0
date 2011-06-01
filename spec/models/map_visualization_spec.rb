require 'spec_helper'
describe MapVisualization do

  describe "paginate_report" do
    before(:each) do
      @attribute = {
        :id    => 1,
        :from  => "2008-10-10",
        :to    => "2010-10-10",
        :type  => "Pf",
        :page  => 1
      }
      @place = Country.create! :name => "National", :code => "National"
      @conditions = :conditions

      MapVisualization.stub!(:get_paginate_conditions).with(@attribute).and_return(@conditions)

      @paginate_options = {
        :page => 1,
        :per_page => 10 ,
      }

      Place.stub!(:find).with(@attribute[:id]).and_return(@place)
      Report.stub!(:paginate).with(@paginate_options).and_return(:report)
    end

    it "should find a place with id " do
      Place.should_receive(:find).with(@attribute[:id]).and_return(@place)
      MapVisualization.paginate_report @attribute
    end

    it "should paginate report accordingly" do
      Report.should_receive(:paginate).with(@paginate_options).and_return(:report)
      MapVisualization.paginate_report(@attribute)
    end
  end

  describe "report_case_count" do
     before(:each) do
       @creteria = Creteria.new
       Creteria.stub!(:new).and_return(@creteria)
       @creteria.stub!(:"add_record!")
       @creteria.stub!(:"prepare!")
       @creteria.stub!(:cloud)
     end
     describe "report case count for whole country" do
        before(:each) do

           @attribute = {
             :id     => 0 ,
             :from   => "2008-10-10" ,
             :to     => "2010-10-10",
             :type   => "Pf"
           }
           @country = Country.create! :name=>"National" , :code =>"National"
           Report.stub!(:count)
           Place.stub!(:find_by_type).and_return @country

        end

        it "should count all the report  " do
           Report.should_receive(:count)
           MapVisualization.report_case_count @attribute
        end

        it "should find a country " do
          Place.should_receive(:find_by_type).with("Country").and_return @country
          MapVisualization.report_case_count @attribute
        end

        it "should build cloud icon" do
          Creteria.should_receive(:new).and_return(@creteria)
          @creteria.should_receive(:"add_record!")
          @creteria.should_receive(:"prepare!")
          @creteria.should_receive(:"cloud")
          MapVisualization.report_case_count @attribute
        end
     end

    describe "report case count for a place" do
      before(:each) do

        @country = Country.create! :name=>"National" , :code =>"National"
        @province = Province.create! :name=>"KompongCham", :code=>"KC1234", :parent_id => @country.id

        @attribute = {
             :id     => 2 ,
             :from   => "2008-10-10" ,
             :to     => "2010-10-10",
             :type   => "Pf"
           }

        @place_results = [
            { "name" => "V1", "total" =>1 },
            { "name" => "V2", "total" =>1 }
        ]

        @connection = ""
        Place.stub!(:find).with(2).and_return(@province)
        MapVisualization.stub!(:get_report_case_count_query).and_return(:sql)
        Place.stub!(:connection).and_return(@connection)
        @connection.stub!(:select_all).and_return(@place_results)

      end

      it "should find and return a place" do
        Place.should_receive(:find).with(2).and_return(@province)
        MapVisualization.report_case_count @attribute
      end

      it "should get the sql query for the place" do
        MapVisualization.should_receive(:get_report_case_count_query).with(2,"2008-10-10","2010-10-10","Pf","Province").and_return(:sql)
        MapVisualization.report_case_count @attribute
      end

      it "should make a sql query and return places with name and total" do
         Place.should_receive(:connection).and_return(@connection)
         @connection.should_receive(:select_all).and_return(@place_results)

        MapVisualization.report_case_count(@attribute)

      end


      it "should build cloud icon" do
          Creteria.should_receive(:new).and_return(@creteria)
          @creteria.should_receive(:"add_record!")
          @creteria.should_receive(:"prepare!")
          @creteria.should_receive(:"cloud")
          MapVisualization.report_case_count @attribute
      end
    end
  end


end
