class AddDayToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :day, :integer, :default => nil
  end

  def self.down
    remove_column :reports, :day
  end
end
