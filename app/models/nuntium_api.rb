class NuntiumAPI
  def initialize service_url, account_name, application_name, application_password
    @api = Nuntium.new service_url, account_name, application_name, application_password
  end

  def send_sms message
    @api.send_ao message
  end

  
end
