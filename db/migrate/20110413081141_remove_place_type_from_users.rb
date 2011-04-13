class RemovePlaceTypeFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :place_type
  end

  def self.down
    add_column :users, :place_type, :string
  end
end
