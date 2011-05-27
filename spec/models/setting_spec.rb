require 'spec_helper'

describe Setting do
  before(:each) do
    allow_message_expectations_on_nil
    @attrib = {
      :provincial_alert => 10,
      :national_alert => 20,
      :admin_alert => 30
    }
    @setting1 = Setting.create!(:param =>"provincial_alert", :value => @attrib[:provincial_alert] );
  end

  describe "get key value" do
    it "should return nil when key doesn't exist" do
      key = "not_exist"
      Setting.stub!(:find_by_param).with(key).and_return(false)
      Setting[key].should == ''

    end

    it "should return a value of key if the key exist " do
      Setting.stub!(:find_by_param).with(:provincial_alert).and_return(@setting1)
      @setting1.value.should == 10
    end
  end

  describe "set key a value " do
    before(:each) do

    end
    describe "key exist" do
      before(:each) do
        Setting.stub!(:find_by_param).with(:provincial_alert).and_return(@setting1)
        @settign1.stub!(:value=).with(20)
        @setting1.stub!(:save!)
      end

      it "should find key and return an setting object " do
        Setting.should_receive(:find_by_param).with(:provincial_alert).and_return(@setting1)
        @setting1.should_receive(:value=).with(20)
        @setting1.should_receive(:save!).and_return(true)
        Setting[:provincial_alert] = 20
      end
    end

    describe "key doesnt exist" do
      before(:each) do
        @key = "key_not_exist"
        @value = 20
        @setting = Setting.new(:param=>@key)
        Setting.stub!(:find_by_param).with(@key).and_return(false)
        Setting.stub!(:new).with(:param => @key).and_return(@setting)
      end

      it "should create a new setting obj" do
        Setting.should_receive(:new).with(:param=> @key)
        Setting[@key] = @value
      end

      it "should set the value for the new setting obj and save it" do
        @setting.should_receive(:value=).with(@value)
        @setting.should_receive(:save!).and_return(true)

        Setting[@key] = @value
      end

    end
  end

end
