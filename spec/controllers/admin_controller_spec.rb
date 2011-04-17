require 'spec_helper'
require 'test_helper'

describe AdminController do
  include Helpers

  #Delete this example and add some real ones
  it "should use AdminController" do
    controller.should be_an_instance_of(AdminController)
  end

  describe "import csv" do
    describe "show import form sucess" do
      before(:each) do
        @user = national_user "12345678"
      end

      it "should render at /admin/import" do
        test_sign_in(@user) #sign the user in
        controller.signed_in?.should be_true #make sure it was signed

        get "import"
        response.should render_template "import"
      end
    end
  end
end
