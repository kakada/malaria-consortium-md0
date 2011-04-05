class CreateHealthCenters < ActiveRecord::Migration
  def self.up
    create_table :health_centers do |t|
      t.string :name
      t.string :name_kh
      t.string :code

      t.timestamps
    end
  end

  def self.down
    drop_table :health_centers
  end
end
