class AddAbbreToPlace < ActiveRecord::Migration
  def self.up
  	add_column :places, :abbr , :string
  end

  def self.down
  	remove_column :places, :abbr
  end
end
