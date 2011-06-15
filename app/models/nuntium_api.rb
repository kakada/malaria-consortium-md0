class NuntiumAPI
  def initialize service_url, account_name, application_name, application_password
    @api = Nuntium.new service_url, account_name, application_name, application_password
  end
end
