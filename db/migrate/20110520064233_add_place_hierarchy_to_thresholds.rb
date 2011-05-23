class AddPlaceHierarchyToThresholds < ActiveRecord::Migration
  def self.up
    add_column :thresholds, :place_hierarchy, :string

    Threshold.reset_column_information
    Threshold.includes(:place).all.each do |th|
      th.save
    end
  end

  def self.down
    remove_column :thresholds, :place_hierarchy
  end
end
