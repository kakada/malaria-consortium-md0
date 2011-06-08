class RemoveStatusFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :status
  end

  def self.down
    add_column :users, :status, :boolean, :default => true
  end
end
