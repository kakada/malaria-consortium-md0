class DropVillagesHealthCentersDistrictsAndProvinces < ActiveRecord::Migration
  def self.up
    drop_table :villages
    drop_table :districts
    drop_table :health_centers
    drop_table :provinces
  end

  def self.down
    create_table :provinces do |t|
      t.string :name
      t.string :name_kh
      t.string :code
      t.timestamps
    end
    
    create_table :districts do |t|
      t.string :name
      t.string :name_kh
      t.string :code
      t.timestamps
      t.references :province
    end
    
    create_table :health_centers do |t|
      t.string :name
      t.string :name_kh
      t.string :code
      t.timestamps
      t.references :district
    end
    
    create_table :villages do |t|
      t.string :name
      t.string :name_kh
      t.string :code
      t.timestamps
      t.references :health_center
      t.references :district
    end
  end
end
