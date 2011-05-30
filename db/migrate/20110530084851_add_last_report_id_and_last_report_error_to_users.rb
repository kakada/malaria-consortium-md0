class AddLastReportIdAndLastReportErrorToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_report_id, :integer
    add_column :users, :last_report_error, :boolean
  end

  def self.down
    remove_column :users, :last_report_error
    remove_column :users, :last_report_id
  end
end
