require "spec_helper"

describe Referal::MessageFormat do
  describe ".real_format" do
    it "should return 'format' from string '{format}' " do
       real_format = Referal::MessageFormat.raw_format("{phone_number}")
       real_format.should eq "phone_number"
    end
  end
end