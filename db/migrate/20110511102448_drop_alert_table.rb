class DropAlertTable < ActiveRecord::Migration
  def self.up
    drop_table :alerts
  end

  def self.down
    create_table :alerts do |t|
      t.integer :threshold
      t.references :recipient
      t.references :source
      t.string :type
      t.timestamps
    end
  end
end
