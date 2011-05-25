class AddHierarchyToPlaces < ActiveRecord::Migration
  def self.up
    add_column :places, :hierarchy, :string

    [Province, OD, HealthCenter, Village].each do |place_class|
      puts "Setting hierarchy ids for #{place_class.name}(s)"
      place_class.reset_column_information
      places = place_class.includes(:parent).all.to_a
      places.each_with_index do |place, i|
        place.save
        STDOUT.write "#{i}/#{places.count}\r"
      end
    end
  end

  def self.down
    remove_column :places, :hierarchy
  end
end
