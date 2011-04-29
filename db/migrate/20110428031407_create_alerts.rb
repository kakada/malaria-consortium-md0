class CreateAlerts < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|
      t.integer :threshold
      t.references :recipient
      t.references :source
      t.timestamps
    end
    
    execute <<-SQL
      ALTER TABLE alerts
        ADD CONSTRAINT fk_alerts_recipient
        FOREIGN KEY (recipient_id)
        REFERENCES places(id)
    SQL
    
    execute <<-SQL
      ALTER TABLE alerts
        ADD CONSTRAINT fk_alerts_source
        FOREIGN KEY (source_id)
        REFERENCES places(id)
    SQL
  end

  def self.down
    execute "ALTER TABLE alerts DROP FOREIGN KEY fk_alerts_source"
    execute "ALTER TABLE alerts DROP FOREIGN KEY fk_alerts_recipients"
  
    drop_table :alerts
  end
end
