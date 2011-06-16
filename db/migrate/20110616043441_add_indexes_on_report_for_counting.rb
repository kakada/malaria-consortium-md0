class AddIndexesOnReportForCounting < ActiveRecord::Migration
  def self.up
    add_index :reports, [:error, :village_id, :created_at]
  end

  def self.down
    remove_index :reports, [:error, :village_id, :created_at]
  end
end
