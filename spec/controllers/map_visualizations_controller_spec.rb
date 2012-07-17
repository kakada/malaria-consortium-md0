require 'spec_helper'

describe MapVisualizationsController do
  include Devise::TestHelpers

  before(:each) do
    @attributes = {
       'id' => 1,
       'from' => "2008-01-10",
       'to' =>   "2009-01-01",
       'type' => "All" ,
       'page' => 0
    }
    @place = "place"
    Place.stub!(:find).with(1).and_return(@place)
    MapVisualization.stub!(:paginate_report).with(@attributes).and_return(:reports)

    @user = User.make :admin
    sign_in @user
  end

  describe "GET index with pagination " do
    before(:each) do
      @reports = []
    end
    
    it "should get paginated reports " do
      MapVisualization.should_receive(:paginate_report).with(@attributes).and_return(@reports)
      @reports.should_receive(:all).and_return([])
      
      get :index, @attributes
    end

    it "should set the id and reports " do
      MapVisualization.should_receive(:paginate_report).with(@attributes).and_return(@reports)
      @reports.should_receive(:all).and_return(@reports)
    
      get :index , @attributes
      assigns[:place].should == @place
      assigns[:reports].should == @reports
    end

    it "should render the page index and pagination without layouts" do
      MapVisualization.should_receive(:paginate_report).with(@attributes).and_return(@reports)
      @reports.should_receive(:all).and_return(@reports)
    
      get :index , @attributes
      response.should render_template(:index)
      response.should_not render_template("layouts/application")
    end
  end

  describe "Get map_report" do
    before(:each) do
     @attributes = {
       'id' => 1,
       'from' => "2008-01-10",
       'to' =>   "2009-01-01",
       'type' => "All" ,
     }
     MapVisualization.stub!(:report_case_count).with(@attributes).and_return(:report)
    end

    it "should count report case " do
      MapVisualization.should_receive(:report_case_count).with(@attributes).and_return(:report)
      get "map_report", @attributes
    end

    it "should render as json format" do
      get :map_report , @attributes
      response.content_type.should  == "application/json"
    end
  end


  describe "Get map view " do
    it "should set place_id" do
      get :map_view , {:place =>0 }
      assigns[:place_id].should_not be_nil
    end

    it "should render the map_view template" do
      get :map_view
      response.should render_template "map_view"
    end
  end
end
