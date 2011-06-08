# encoding: UTF-8

require 'csv'

class PlaceImporter

  def initialize file
    @file = file
  end

  def import
    process_csv
  end

  def simulate
    process_csv :simulate => true
  end

  private

  def process_csv(options = {})
    simulate = options[:simulate]

    existing_places = Hash[Place.all.map{|x| [x.code, x]}]
    new_places = []
    levels = Place::Types[1..-1].map(&:constantize)

    CSV.foreach @file, :headers => :first_row, :skip_blanks => true do |row|
      parent = nil

      levels.each do |level|
        fields = fill_fields row, level, :parent => parent
        existing_place = existing_places[fields[:code]]
        if existing_place
          parent = existing_place
        else
          parent = simulate ? level.new(fields) : level.create(fields)
          existing_places[parent.code] = parent
          new_places << parent
        end
      end
    end

    new_places
  end

  CSVIndexes = {
    Province => { :name => 0, :name_kh => 1, :code => 2 },
    OD => { :name => 3, :name_kh => 4, :code => 5 },
    HealthCenter => { :name => 6, :name_kh => 7, :code => 8 },
    Village => { :name => 9, :name_kh => 10, :code => 11, :lat => 12, :lng => 13 }
  }

  ColumnNames = {
    :name => 'name',
    :name_kh => 'name (khmer)',
    :code => 'code',
    :lat => 'latitude',
    :lng => 'longitude'
  }

  def fill_fields row, place_type, extensions
    fields = {}
    CSVIndexes[place_type].each do |name, column_index|
      fields[name] = row[column_index]
    end
    fields.merge!(extensions)
    fields
  end

  def self.column_headers
    headers = []
    column_count.times do |column_index|
      CSVIndexes.each do |place, fields|
        fields.each do |key, number|
          if column_index == number
            headers << "#{titleize place} #{ColumnNames[key]}"
          end
        end
      end
    end
    headers
  end

  def self.column_count
    count = 0
    CSVIndexes.each { |place, fields| count += fields.count }
    count
  end

  def self.titleize(place)
    place == OD ? "OD" : place.name.titleize
  end
end
