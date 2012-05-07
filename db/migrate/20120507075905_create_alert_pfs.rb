class CreateAlertPfs < ActiveRecord::Migration
  def self.up
    create_table :alert_pfs do |t|
      t.text :provinces

      t.timestamps
    end
  end

  def self.down
    drop_table :alert_pfs
  end
end
