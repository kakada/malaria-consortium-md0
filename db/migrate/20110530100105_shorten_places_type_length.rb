class ShortenPlacesTypeLength < ActiveRecord::Migration
  def self.up
    change_column :places, :type, :string, :limit => 15
  end

  def self.down
    change_column :places, :type, :string
  end
end
