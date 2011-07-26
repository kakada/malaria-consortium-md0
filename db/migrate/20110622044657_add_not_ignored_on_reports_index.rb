class AddNotIgnoredOnReportsIndex < ActiveRecord::Migration
  Types = :country, :province, :od, :health_center, :village, :place

  def self.up
    begin
      Types.each do |type|
        remove_index :reports, ["#{type}_id", :error]
        add_index :reports, ["#{type}_id", :error, :ignored]
      end
      remove_index :reports, [:error, :village_id, :created_at]
      add_index :reports, [:error, :ignored, :village_id, :created_at]
    rescue
    end

  end

  def self.down
    begin
      Types.each do |type|
        remove_index :reports, ["#{type}_id", :error, :ignored]
        add_index :reports, ["#{type}_id", :error]
      end
      remove_index :reports, [:error, :ignored, :village_id, :created_at]
      add_index :reports, [:error, :village_id, :created_at]
    rescue
    end
  end
end
