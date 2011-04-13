class AddPlaceTypeToPlaces < ActiveRecord::Migration
  def self.up
    add_column :places, :place_type, :string
  end

  def self.down
    remove_column :places, :place_type
  end
end
