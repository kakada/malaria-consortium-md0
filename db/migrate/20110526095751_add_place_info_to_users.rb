class AddPlaceInfoToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :place_class, :string
    add_column :users, :health_center_id, :integer
    add_column :users, :od_id, :integer
    add_column :users, :province_id, :integer
  end

  def self.down
    remove_column :users, :health_center_id
    remove_column :users, :od_id
    remove_column :users, :province_id
    remove_column :users, :place_class
  end
end
