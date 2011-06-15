require 'spec_helper'

describe String do
  it "apply template with hash" do
    template = 'Age: {age}, Name: {name}'
    values = {:age => 23, :name => 'Foo Bar'}
    template.apply(values).should == 'Age: 23, Name: Foo Bar'
  end

  it "replace with question marks if key is missing" do
    template = 'Age: {age}, Name: {name}'
    template.apply({}).should == 'Age: ??, Name: ??'
  end

  it "apply template with string keys" do
    template = 'Age: {age}, Name: {name}'
    values = {"age" => 23, "name" => 'Foo Bar'}
    template.apply(values).should == 'Age: 23, Name: Foo Bar'
  end
end
