require "spec_helper"

describe  Referral do
  include Referral::ReferralHelper
  
  it "should return current url with csv format" do
    current_url("http://www.test.com/search", {}, "csv").should eq "http://www.test.com/search.csv"
  end
  
  it "should return current url with format appending to the domain with the query string" do
    url = current_url("http://www.test.com/search", { "query" => "research", "name" => "my brother"}, "csv")
    url.should eq "http://www.test.com/search.csv?query=research&name=my%20brother"
  end
  
  it "should return current url with format appending to the domain and existing query_string" do
    url = current_url("http://www.test.com/search?query=qsm", { "date" => "2012-12-30", "name" => "my brother"}, "csv")
    url.should eq "http://www.test.com/search.csv?query=qsm&date=2012-12-30&name=my%20brother"
  end
   
end