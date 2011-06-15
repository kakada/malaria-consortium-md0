module Helpers
  def assert_parse_error body, error_message
    @parser.parse body
    @parser.errors?().should == true
    @parser.error.should == @parser.class.send(error_message, body)
    @parser.report.error_message == error_message.to_s.gsub('_', ' ')
  end
end
