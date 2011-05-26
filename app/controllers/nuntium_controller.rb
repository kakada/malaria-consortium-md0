class NuntiumController < ApplicationController
  before_filter :authenticate
  around_filter :transact

  def receive_at
    render :json => Report.process(params)
  end

  private

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == Nuntium::Config['incoming_username'] && password == Nuntium::Config['incoming_password']
    end
  end

  def transact
    User.transaction do
      yield
    end
  end
end
