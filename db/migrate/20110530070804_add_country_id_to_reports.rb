class AddCountryIdToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :country_id, :integer
  end

  def self.down
    remove_column :reports, :country_id
  end
end
