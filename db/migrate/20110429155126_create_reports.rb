class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.string :malaria_type
      t.string :sex
      t.integer :age
      t.boolean :mobile
      t.string :type

      t.references :sender
      t.references :place
      
      t.timestamps
    end
    
    execute <<-SQL
          ALTER TABLE reports
            ADD CONSTRAINT fk_reports_users
            FOREIGN KEY (sender_id)
            REFERENCES users(id)
        SQL
        
    execute <<-SQL
          ALTER TABLE reports
            ADD CONSTRAINT fk_reports_places
            FOREIGN KEY (place_id)
            REFERENCES places(id)
        SQL
                        
  end

  def self.down
    execute "ALTER TABLE reports DROP FOREIGN KEY fk_reports_places"
    execute "ALTER TABLE reports DROP FOREIGN KEY fk_reports_users"    
    drop_table :reports
  end
end
