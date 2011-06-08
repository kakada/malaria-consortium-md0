class DropPhoneNumberUniqueIndexFromUsers < ActiveRecord::Migration
  def self.up
    remove_index :users, :phone_number
  end

  def self.down
    add_index :users, :phone_number, :unique => true
  end
end
