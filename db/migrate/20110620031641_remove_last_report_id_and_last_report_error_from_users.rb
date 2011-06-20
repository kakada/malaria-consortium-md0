class RemoveLastReportIdAndLastReportErrorFromUsers < ActiveRecord::Migration
  def self.up
    remove_index :users, [:last_report_error, :updated_at]
    remove_column :users, :last_report_error
    remove_column :users, :last_report_id
  end

  def self.down
    add_column :users, :last_report_id, :integer
    add_column :users, :last_report_error, :boolean
    add_index :users, [:last_report_error, :updated_at]
  end
end
