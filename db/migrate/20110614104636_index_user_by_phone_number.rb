class IndexUserByPhoneNumber < ActiveRecord::Migration
  def self.up
    add_index :users, :phone_number
  end

  def self.down
    remove_index :users, :phone_number
  end
end
