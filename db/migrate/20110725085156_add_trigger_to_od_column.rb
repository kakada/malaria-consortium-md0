class AddTriggerToOdColumn < ActiveRecord::Migration
  def self.up
    add_column :reports, :trigger_to_od, :boolean
  end

  def self.down
    remove_column :reports, :trigger_to_od
  end
end
