require 'spec_helper'
describe PlacesController do
  include Devise::TestHelpers

  before(:each) do
    sign_in User.make(:admin)
  end

  describe "Import places" do
    it "should render 'no places to create' template" do
      importer_stub = {}
      PlaceImporter.stub!(:new).and_return(importer_stub)
      importer_stub.stub!(:simulate).and_return([])
      controller.current_user.stub!(:write_places_csv)

      post :upload_csv, :admin => {}

      response.should render_template "no_places_to_import"
    end
  end
end
