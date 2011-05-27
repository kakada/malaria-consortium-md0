class AddCountryIdToUser < ActiveRecord::Migration

  def self.up
    add_column :users, :country_id, :integer
    add_column :users, :village_id, :integer
  end

  def self.down
    remove_column :users, :country_id
    remove_column :users, :village_id
  end

  
end
