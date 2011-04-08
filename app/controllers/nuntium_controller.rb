class NuntiumController < ApplicationController
  before_filter :authenticate

  def receive_at
    User.transaction do
      result = Report.process(params)
      puts "======================"
      puts result
      puts "======================"
      render :json => result
    end
  end

  private

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "test" && password == "test"
    end
  end
end
