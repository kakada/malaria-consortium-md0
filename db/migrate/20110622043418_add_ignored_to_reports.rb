class AddIgnoredToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :ignored, :boolean, :default => false
  end

  def self.down
    remove_column :reports, :ignored
  end
end
