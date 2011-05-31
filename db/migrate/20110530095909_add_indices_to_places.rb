class AddIndicesToPlaces < ActiveRecord::Migration
  def self.up
    add_index :places, :type
    add_index :places, [:parent_id, :name]
  end

  def self.down
    remove_index :places, :type
    remove_index :places, [:parent_id, :name]
  end
end
