class User < ActiveRecord::Base
  belongs_to :place, :polymorphic => true

  validates_confirmation_of :password


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
    save_without_validation
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
end
