class AddHierarchyToPlaces < ActiveRecord::Migration
  def self.up
    add_column :places, :hierarchy, :string
  end

  def self.down
    remove_column :places, :hierarchy
  end
end
