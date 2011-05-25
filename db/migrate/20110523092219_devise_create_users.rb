class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    change_column :users, :encrypted_password, :string, :null => false, :default => '', :limit => 128
    change_table :users do |t|
      # if you already have a email column, you have to comment the below line and add the :encrypted_password column manually (see devise/schema.rb).
      #t.database_authenticatable
      #t.confirmable
      t.recoverable
      t.rememberable
      t.trackable

      # t.encryptable
      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable
      #t.timestamps
    end

    #add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
    # add_index :users, :authentication_token, :unique => true
  end

  def self.down
    change_column :users, :encrypted_password, :string

    change_table :users do |t|
      #t.remove :password_salt
      #t.remove :authentication_token
      #t.remove :confirmation_token
      #t.remove :confirmed_at
      #t.remove :confirmation_sent_at
      t.remove :reset_password_token
      t.remove :reset_password_sent_at
      #t.remove :remember_token
      t.remove :remember_created_at
      t.remove :sign_in_count
      t.remove :current_sign_in_at
      t.remove :last_sign_in_at
      t.remove :current_sign_in_ip
      t.remove :last_sign_in_ip
      #t.remove :failed_attempts
      #t.remove :unlock_token
      #t.remove :locked_at
    end
  end
end
