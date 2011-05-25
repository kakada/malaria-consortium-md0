class AddHealthcenterOdProvinceToReport < ActiveRecord::Migration
  def self.up
    add_column :reports, :health_center_id, :integer, :default =>0
    add_column :reports, :od_id, :integer, :default =>0
    add_column :reports, :province_id, :integer, :default =>0
  end

  def self.down
    remove_column :reports, :health_center_id
    remove_column :reports, :od_id
    remove_column :reports, :province_id
  end
end
