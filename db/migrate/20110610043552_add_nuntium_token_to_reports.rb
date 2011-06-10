class AddNuntiumTokenToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :nuntium_token, :string
  end

  def self.down
    remove_column :reports, :nuntium_token
  end
end
