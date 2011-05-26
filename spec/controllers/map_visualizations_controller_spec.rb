require 'spec_helper'

describe MapVisualizationsController do
  before(:each) do
    @attributes = {
       :id => 1,
       :from => "2008-01-10",
       :to =>   "2009-01-01",
       :type => "All" ,
       :page => 0
    }
    
    MapVisualization.stub!(:paginate_report).with(@attributes).and_return(:reports)

    
  end
  describe "GET index with pagination " do
    it "should get paginated reports " do
      MapVisualization.should_receive(:paginate_report).with(@attributes).and_return(:reports)

      get :index, @attributes
    end

    it "should set the id and reports " do
      get :index , @attributes
      assigns[:id].should == @attributes[:id]
      assigns[:reports].should == :reports
    end

    it "should render the page index and pagination without layouts" do
      get :index , @attributes
      response.should render_template(:index)
      response.should_not render_template("layouts/application")
    end
  end

  describe "Get map_report" do
    before(:each) do
     @attributes = {
       :id => 1,
       :from => "2008-01-10",
       :to =>   "2009-01-01",
       :type => "All" ,
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
    before(:each) do
      @country = Country.create! :name =>"natinal", :code =>"85523"
      Place.stub!(:find_by_type).with("Country").and_return(@country)
    end

    it "should find a country" do
      Place.should_receive(:find_by_type).and_return(@country)
      get :map_view
    end

    it "should set the @country to the view " do
      get :map_view
      assigns[:country].should == @country
    end

    it "should render the map_view template" do
      get :map_view
      response.should render_template "map_view"
    end

  end
end