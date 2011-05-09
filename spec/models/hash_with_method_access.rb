require 'spec_helper'

describe Hash do

  it "should read values with method names" do
    hash = {:foo => 123}
    hash.with_method_access.foo.should == 123
  end

  it "should set values with method names" do
    hash = {}
    hash.with_method_access.foo = 123
    hash[:foo].should == 123
  end

  it "should read nil value with method name" do
    hash = {:foo => nil}
    hash.with_method_access.foo.should == nil
  end

end
