class User < ActiveRecord::Base
  attr_accessor :intended_place_code

  Roles = ["default", "national", "admin" ]

  before_validation :try_fetch_place

  belongs_to :place

  validates_inclusion_of :role, :in => Roles, :allow_nil => true

  validates_uniqueness_of :user_name, :allow_nil => true, :message => 'Belongs to another user'

  validates_uniqueness_of :email, :allow_nil => true, :message => 'Belongs to another user'
  validates_format_of :email, :allow_blank => true , :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,  :message => 'Format not valid'

  validates_confirmation_of :password

  validates_uniqueness_of :phone_number, :allow_nil => true, :message => 'Belongs to another user'

  validates_presence_of :phone_number,
                        :if => Proc.new {|user| user.email.blank? || user.user_name.blank? || user.password.blank?},
                        :message => "Phone can't be blank, unless you provide a username, a password and an email"


  validates_format_of :phone_number, :with => /^\d+$/, :unless => Proc.new {|user| user.phone_number.blank?}, :message => "Only numbers allowed"

  validate :intended_place_code_must_exist

  before_save :encrypt_password
  before_save :set_nuntium_custom_attributes

  # Delegate country, province, etc., to place
  Place::Types.each { |type| delegate type.tableize.singularize, :to => :place }

  def self.authenticate email, pwd
    user = User.find_by_email email

    return nil if user.nil?
    return user if user.has_password? pwd
  end

  def write_places_csv source_file
    File.open(places_csv_file_name,"w+b") do |file|
      file.write(source_file.read)
    end
  end

  def places_csv_directory
    dir = Rails.root.join "tmp", "placescsv"
    Dir.mkdir dir unless Dir.exists? dir
    dir
  end

  def places_csv_file_name
    Rails.root.join(places_csv_directory, "#{id}.csv")
  end

  def has_password? submitted_pwd
    self.encrypted_password == encrypt(submitted_pwd)
  end

  def remember_me!
    self.remember_token = encrypt "#{salt}--#{id}"
    save false
  end

  def alert_numbers
    national_users = User.find_all_by_role "national"

    recipients = []

    recipients.concat User.phone_numbers health_center.users unless place.health_center?
    recipients.concat User.phone_numbers od.users
    recipients.concat User.phone_numbers province.users
    recipients.concat User.phone_numbers national_users
  end

  def can_report?
    place_id && (place.village? || place.health_center?)
  end

  def report_parser
    place.report_parser self
  end

  #data ={:user_name=>[],:password => [] ,...}
  def self.save_bulk data
    users = []
    data[:user_name].each_with_index do |user_name, i|
      attrib = {
         :user_name => user_name,
         :email => data[:email][i],
         :password => data[:password][i],
         :password_confirmation => data[:password][i],
         :intended_place_code => data[:place_code][i],
         :phone_number => data[:phone_number][i],
         :role => data[:role][i]
      }

      user = User.new attrib
      users.push user
    end

    if self.validate_users_bulk? users
      User.transaction  do
         users.each do |user|
            user.save
         end
      end
    end
    users
  end

  def self.validate_users_bulk? users
    users.each do |user|
      return false if user.invalid?
    end
    true
  end

  def self.paginate_user page
    page = page.nil? ? 1 : page.to_i
    User.paginate :page => page, :per_page => 10
  end

  def to_json(options ={})
     options[:except] ||= [:password,:encrypted_password,:salt,:updated_at,:created_at]
     super(options)
  end

  def intended_place_code_must_exist
    errors.add(:intended_place_code, "Place doesn't exist") if !self.intended_place_code.blank? && (self.place_id.blank? || self.place.code != self.intended_place_code)
  end

  private

  def encrypt_password
    unless password.nil?
      self.salt = make_salt
      self.encrypted_password = encrypt password
    end
  end

  def encrypt pwd
    secure_hash "#{salt}#{pwd}"
  end

  def make_salt
    secure_hash "#{Time.now.utc}#{password}"
  end

  def secure_hash string
    Digest::SHA2.hexdigest string
    string
  end

  def self.phone_numbers users
    users.map { |u| u.phone_number }.reject { |n| n.nil? }
  end

  def try_fetch_place
    if !intended_place_code.blank? && (place_id.blank? || place.code != intended_place_code)
      should_be_place = Place.find_by_code intended_place_code
      self.place_id = should_be_place.id unless should_be_place.nil?
    end
  end

  def set_nuntium_custom_attributes
    if phone_number_changed?
      Nuntium.new_from_config.set_custom_attributes "sms://#{phone_number_was}", {:application => nil}
    end
    if phone_number.present?
      Nuntium.new_from_config.set_custom_attributes "sms://#{phone_number}", {:application => Nuntium::Config['application']}
    end
  end
end