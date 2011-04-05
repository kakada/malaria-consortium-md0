class AddPlaceToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
    	t.references :place, :polymorphic => true
	  end
  end

  def self.down
    remove_column :users , :place_id
    remove_column :users , :place_type
  end
end
