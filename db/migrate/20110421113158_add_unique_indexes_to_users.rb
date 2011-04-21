class AddUniqueIndexesToUsers < ActiveRecord::Migration
  def self.up
    add_index :users, :phone_number, :unique => true
    add_index :users, :email, :unique => true
    add_index :users, :user_name, :unique => true
  end

  def self.down
    remove_index :users, :user_name
    remove_index :users, :email
    remove_index :users, :phone_number
  end
end
