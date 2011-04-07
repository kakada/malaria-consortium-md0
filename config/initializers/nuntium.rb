class Nuntium
  Config = YAML.load_file(File.expand_path('../../../config/nuntium.yml', __FILE__))[Rails.env]
  def self.new_from_config
    Nuntium.new Config['url'], Config['account'], Config['application'], Config['password']
  end
end

class String
  def to_sms_addr
    "sms://"+ self
  end

  def parse_phone_number
    self.split('://')[1]
  end
end