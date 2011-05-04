class AddVillageToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :village_id, :integer

    execute <<-SQL
          ALTER TABLE reports
            ADD CONSTRAINT fk_reports_village
            FOREIGN KEY (village_id)
            REFERENCES places(id)
        SQL
  end

  def self.down
    execute "ALTER TABLE reports DROP FOREIGN KEY fk_reports_village"
    remove_column :reports, :village_id
  end
end
