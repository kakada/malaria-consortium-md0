class AddAppUserToUserTable < ActiveRecord::Migration
  def self.up
    add_column :users, :apps_mask , :integer, :default => 1
  end

  def self.down
    remove_column :users, :apps_mask
  end
end
