require 'spec_helper'

describe AdminController do

  #Delete this example and add some real ones
  it "should use AdminController" do
    controller.should be_an_instance_of(AdminController)
  end

  describe "import csv" do
    describe "show import form sucess" do

      it "should render at /admin/import" do
        get "import"
        response.should render_template "import"
      end

      
    end

  end

end
