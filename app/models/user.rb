class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :password_length => 1..128

  attr_accessor :intended_place_code
  
  ROLE_MC_DEFAULT = "default"
  ROLE_MC_NAT = "national"
  ROLE_MC_ADMIN = "admin"
  
  ROLE_REF_PROVIDER = "provider"
  ROLE_REF_HC = "health center"
  
  Roles = [ROLE_MC_DEFAULT, ROLE_MC_NAT , ROLE_MC_ADMIN ]
  Roles_Ref = [ROLE_REF_PROVIDER, ROLE_REF_HC]
  
  Status = ["Deactive", "Active"]

  
  

  class << self
    def activated
      self.where :status => true
    end
    
    def mc_users
      default_scope where(["role != ? AND role != ? ", ROLE_REF_PROVIDER , ROLE_REF_HC ])
    end
    
    def ref_users
      self.where
    end
    
    def deactivated
      self.where :status => false
    end
  end
  
  belongs_to :place
  has_many :reports, :foreign_key => 'sender_id', :dependent => :destroy

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

  #default_scope where(["role != ? AND role != ? ", ROLE_REF_PROVIDER , ROLE_REF_HC ])
  
  
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
    place_id && self.status && (place.village? || place.health_center?)
  end

  def report_parser
    place.report_parser self
  end

  def address
    phone_number.with_sms_protocol
  end

  def status_description
    self.class::Status[self.status ? 1: 0 ]
  end

  def self.from_status status
     self::Status.find_index(status) == 0 ? false : true
  end

  def message(body)
    {:to => address, :body => body}
  end


  def self.user_from_place place_id, place_type
    place = (place_id == 0 || place_id.nil?) ? Country.first : Place.find(place_id)
    User.activated.where place.foreign_key => place.id, :place_class => place_type
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
    @users = self.search options
    @users = @users.paginate :page => (options[:page] || '1').to_i, :per_page => options[:per_page]
  end

  def self.search options
    if(options[:query].present?)
      query = options[:query]
      @users = User.joins(" INNER JOIN places ON users.place_id = places.id ")
      @users = @users.where "users.user_name LIKE :q OR users.phone_number LIKE :q OR places.code LIKE :q OR places.name LIKE :q ", :q => "#{query}%"

      if(options[:type].present?)
        @users = @users.where("place_class = :type", :type => options[:type] )
      end

      @users = @users.order(options[:order])

    else
      if(options[:type].present?)
         @users = User.where("place_class = :type", :type => options[:type])
         @users = @users.includes(:place).order(options[:order])
      else
         @users = User.includes(:place).order(options[:order])
      end
    end
    @users
  end

  def self.count_user place=nil
    users = []
    if place
        users.push :place => place.class, :users => (User.activated.where(["place_class = ?  and place_id = ? ",place.class.to_s, place.id ]  ) )

        options = {}
        options[place.foreign_key] = place.id

        Place::Types.from(Place::Types.index(place.class.to_s) + 1).each do |type|
          options[:place_class] = type
          users.push :place => type.constantize, :count => User.activated.where(options).count
        end
    else
        Place::Types.from(1).each do |type|
          users.push :place => type.constantize, :count => User.activated.where(:place_class => type).count
        end
    end
    users
  end

  def self.get_admin_user
    User.where :role => "admin"
  end

  def admin?
    role == 'admin'
  end

  def update_params attributes
    state = self.update_attributes(attributes)
    if state
      self.reload
      set_place_class_and_hierarchy
      self.save
    end
    state
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