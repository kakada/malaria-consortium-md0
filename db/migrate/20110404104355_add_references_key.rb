class AddReferencesKey < ActiveRecord::Migration
  def self.up
		change_table :districts do |t|
    	t.references :province
	  end

		
		change_table :villages do |t|
    	t.references :district
			t.references :health_center
	  end


		change_table :health_centers do |t|
    	t.references :district
	  end

  end

  def self.down
		remove_column :districts, :province_id
		remove_column :villages, :district_id
		remove_column :villages, :health_center_id
		remove_column :health_centers, :district_id
  end
end
