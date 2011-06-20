class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :password_length => 1..128

  attr_accessor :intended_place_code

  Roles = ["default", "national", "admin" ]

  belongs_to :place
  belongs_to :last_report, :class_name => 'Report'
  has_many :reports, :foreign_key => 'sender_id'

  before_validation :try_fetch_place

  validates_inclusion_of :role, :in => Roles, :allow_nil => true
  validates_uniqueness_of :user_name, :allow_nil => true, :message => 'Belongs to another user'
  validates_uniqueness_of :phone_number, :allow_nil => true, :message => 'Belongs to another user', :if => :phone_number?
  validates_presence_of :phone_number,
                        :if => Proc.new {|user| user.email.blank? || user.user_name.blank? || user.encrypted_password.blank?},
                        :message => "Phone can't be blank, unless you provide a username, a password and an email"
  validates_format_of :phone_number, :with => /^\d+$/, :unless => Proc.new {|user| user.phone_number.blank?}, :message => "Only numbers allowed"
  validate :intended_place_code_must_exist

  before_save :set_place_class_and_hierarchy, :if => :place_id?
  before_save :set_nuntium_custom_attributes
  before_destroy :remove_nuntium_custom_attributes

  # Delegate country, province, etc., to place
  Place::Types.each { |type| delegate type.tableize.singularize, :to => :place }

  def write_places_csv source_file
    File.open(places_csv_file_name,"w+b") do |file|
      file.write(source_file.read)
    end
  end

  def places_csv_directory
    dir = Rails.root.join "tmp", "placescsv"
    FileUtils.mkdir_p dir unless Dir.exists? dir
    dir
  end

  def places_csv_file_name
    Rails.root.join(places_csv_directory, "#{id}.csv")
  end

  def can_report?
    place_id && (place.village? || place.health_center?)
  end

  def report_parser
    place.report_parser self
  end

  def address
    phone_number.with_sms_protocol
  end

  def message(body)
    {:to => address, :body => body}
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

  def self.find_by_phone_number(phone_number)
    where(:phone_number => phone_number.without_protocol.strip).first
  end

  def to_json(options ={})
     options[:except] ||= [:password,:encrypted_password,:salt,:updated_at,:created_at]
     super(options)
  end

  def self.paginate_user(options={})
    if(options[:query].present?)
      query = options[:query]
      @users = User.joins(" INNER JOIN places ON users.place_id = places.id ")
      @users  = @users.where "users.user_name LIKE :q OR users.phone_number LIKE :q OR places.code LIKE :q OR places.name LIKE :q ", :q => "#{query.strip}%"
      @users = @users.order(options[:order])
    else
      @users = User.includes(:place).order(options[:order]).all
    end
    @users = @users.paginate :page => (options[:page] || '1').to_i, :per_page => options[:per_page]
  end

  def admin?
    role == 'admin'
  end

  private

  def self.phone_numbers users
    users.map { |u| u.phone_number }.reject { |n| n.nil? }
  end

  def try_fetch_place
    if intended_place_code.present? && (place_id.blank? || place.code != intended_place_code)
      should_be_place = Place.find_by_code intended_place_code
      self.place_id = should_be_place.id unless should_be_place.nil?
    end
  end

  def set_nuntium_custom_attributes
    if phone_number_changed? && phone_number_was.present?
      old_place = place_id_changed? ? Place.find(place_id_was) : place rescue nil
      if is_reporting_place?(old_place)
        Nuntium.new_from_config.set_custom_attributes "sms://#{phone_number_was}", {:application => nil}
      end
    end
    if phone_number.present?
      if is_reporting_place?(place)
        Nuntium.new_from_config.set_custom_attributes "sms://#{phone_number}", {:application => Nuntium::Config['application']}
      elsif !new_record? && !phone_number_changed? && place_id_changed?
        Nuntium.new_from_config.set_custom_attributes "sms://#{phone_number}", {:application => nil}
      end
    end
  end

  def remove_nuntium_custom_attributes
    if phone_number.present? && is_reporting_place?(place)
      Nuntium.new_from_config.set_custom_attributes "sms://#{phone_number}", {:application => nil}
    end
  end

  def is_reporting_place?(place)
    place.is_a?(HealthCenter) || place.is_a?(Village)
  end

  def intended_place_code_must_exist
    errors.add(:intended_place_code, "Place doesn't exist") if self.intended_place_code.present? && (self.place_id.blank? )
  end

  def email_required?
    phone_number.nil?
  end

  def password_required?
    phone_number.nil?
  end

  def set_place_class_and_hierarchy
    self.place_class = self.place.class.to_s
    parent = self.place
    while parent
      self.send "#{parent.foreign_key}=", parent.id
      parent = parent.parent
    end
  end
end
