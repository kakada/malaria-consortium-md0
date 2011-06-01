require 'spec_helper'

describe Templates do
  describe "assign to single village case template" do
    it "saves and creates a Setting" do
      subject.single_village_case_template = 'Found {malaria_type}'
      subject.save.should == true

      settings = Setting.all
      settings.count.should == 1
      settings[0].param.should == 'single_village_case_template'
      settings[0].value.should == 'Found {malaria_type}'
    end

    it "doesn't save because of an incorrect template parameter" do
      subject.single_village_case_template = 'Found {something}'
      subject.save.should == false

      Setting.count.should == 0
      subject.errors.count.should == 1
      subject.errors[:single_village_case_template].should == ["Incorrect parameter: {something}"]
    end
  end
end

