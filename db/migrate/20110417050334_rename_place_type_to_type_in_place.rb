class RenamePlaceTypeToTypeInPlace < ActiveRecord::Migration
  def self.up
    rename_column :places, :place_type, :type
  end

  def self.down
    rename_column :places, :type, :place_type
  end
end
