class AddTextAndErrorAndErrorMessageToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :text, :string
    add_column :reports, :error, :boolean
    add_column :reports, :error_message, :string
  end

  def self.down
    remove_column :reports, :error_message
    remove_column :reports, :error
    remove_column :reports, :text
  end
end
