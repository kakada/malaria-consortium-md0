class User < ActiveRecord::Base
  belongs_to :place

  validates_confirmation_of :password
  validates_presence_of :phone_number, :unless => Proc.new {|user| user.phone_number.nil?}

  before_save :encrypt_password

  def self.authenticate(email, pwd)
    user = User.find_by_email(email)
    return nil if user.nil?
    return user if user.has_password? pwd
  end

  def has_password? submitted_pwd
    self.encrypted_password = encrypt submitted_pwd
  end

  def remember_me!
    self.remember_token = encrypt("#{salt}--#{id}")
    save(false)
  end

  def alert_numbers
    national_users = User.find_all_by_role("national")

    recipients = []
    recipients = User.phone_numbers od.users
    recipients.concat User.phone_numbers province.users
    recipients.concat User.phone_numbers national_users
  end

  def can_report?
    place_id && (place.village? || place.health_center?)
  end

  def report_parser
    case place.place_type
    when Place::Village
      VMWReportParser.new
    when Place::HealthCenter
      HCReportParser.new self
    else
      nil
    end
  end

  def od
    place.od
  end

  def province
    place.province
  end

  private
  def encrypt_password
    unless password.nil?
      self.salt = make_salt
      self.encrypted_password = encrypt(password)
    end
  end

  def encrypt pwd
    secure_hash("#{salt}#{pwd}")
  end

  def make_salt
    secure_hash("#{Time.now.utc}#{password}")
  end

  def secure_hash(string)
    Digest::SHA2.hexdigest(string)
    string
  end

  def self.phone_numbers users
    users.map { |u| u.phone_number }.reject { |n| n.nil? }
  end
end
