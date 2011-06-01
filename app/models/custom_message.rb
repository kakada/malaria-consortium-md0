class CustomMessage
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :sms
  validates_presence_of :sms
  validates_length_of :sms, :maximum =>140

  def initialize sms
    @sms = sms
    @nuntium = Nuntium.new_from_config()
  end

  def persisted
    false
  end

  def self.get_users place_id, place_types
    place = place_id == 0 ? Country.first : Place.find(place_id)
    place_id_column = "#{place.class.to_s.tableize.singularize}_id"
    User.where place_id_column => place.id, :place_class => place_types
  end

  def send_sms_users users
    messages = users.map do |user|
      { :from => "sms://md0", :body => @sms, :to => user.phone_number.with_sms_protocol }
    end
    @nuntium.send_ao messages
  end

end
