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
    
    users.each do |user|
      send_to user.phone_number
    end
  end

  def send_to phone
    message = {
                :from => "sms://md0",
                :subject => "",
                :body => @sms,
                :to => phone.with_sms_protocol
     }
     @nuntium.send_ao message
  end

end