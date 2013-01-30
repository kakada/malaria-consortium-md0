require "spec_helper"

describe Referral::MessageFormat do
  describe ".real_format" do
    it "should return 'format' from string '{format}' " do
       real_format = Referral::MessageFormat.raw_format("{phone_number}")
       real_format.should eq "phone_number"
    end
  end
end