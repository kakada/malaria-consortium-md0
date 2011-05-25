class AddLatLngToPlace < ActiveRecord::Migration
  def self.up
    add_column :places, :lat , :decimal, :precision => 11, :scale => 8
    add_column :places, :lng , :decimal, :precision => 11, :scale => 8
  end

  def self.down
    remove_column :places , :lat
    remove_column :places , :lng
  end
end
