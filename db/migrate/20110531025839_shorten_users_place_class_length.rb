class ShortenUsersPlaceClassLength < ActiveRecord::Migration
  def self.up
    change_column :users, :place_class, :string, :limit => 15
  end

  def self.down
    change_column :users, :place_class, :string
  end
end
