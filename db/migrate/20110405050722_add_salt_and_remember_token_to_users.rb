class AddSaltAndRememberTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users , :salt ,:string
    add_column :users, :remember_token ,:string
    add_column :users, :encrypted_password, :string
  end

  def self.down
    remove_column :users, :salt
    remove_column :users, :remove_column
    remove_column :users, :encrypted_password
  end
end
