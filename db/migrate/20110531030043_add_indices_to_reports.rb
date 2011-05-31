class AddIndicesToReports < ActiveRecord::Migration
  Types = :country, :province, :od, :health_center, :village, :place

  def self.up
    Types.each do |type|
      add_index :reports, ["#{type}_id", :error]
    end
  end

  def self.down
    Types.each do |type|
      remove_index :reports, ["#{type}_id", :error]
    end
  end
end
