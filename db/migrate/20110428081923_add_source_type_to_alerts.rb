class AddSourceTypeToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :source_type, :string
  end

  def self.down
    add_column :alerts, :source_type
  end
end
