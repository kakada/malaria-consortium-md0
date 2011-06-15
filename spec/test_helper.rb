module Helpers
  def od name , id = nil
    OD.create! :name => name, :name_kh => name, :code => name, :parent_id => id
  end

  def province name
    Province.create! :name => name, :name_kh => name, :code => name
  end

  def user attribs
    User.create! attribs
  end

  def national_user number
    User.create! :phone_number => number, :role => "national"
  end

  def admin_user number
    User.create! :phone_number => number, :role => "admin"
  end

  def assert_parse_error body, error_message
    @parser.parse body
    @parser.errors?().should == true
    @parser.error.should == @parser.class.send(error_message, body)
    @parser.report.error_message == error_message.to_s.gsub('_', ' ')
  end
end
