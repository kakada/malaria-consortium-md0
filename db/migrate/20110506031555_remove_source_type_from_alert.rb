class RemoveSourceTypeFromAlert < ActiveRecord::Migration
  def self.up
    remove_column :alerts, :source_type
  end

  def self.down
    add_column :alerts, :source_type, :string
  end
end
