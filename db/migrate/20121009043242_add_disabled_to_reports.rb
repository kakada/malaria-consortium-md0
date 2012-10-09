class AddDisabledToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :disabled, :boolean, :default => false
  end

  def self.down
    remove_column :reports, :disabled
  end
end
