# encoding: UTF-8

require 'csv'

class PlaceImporter

  def initialize file
    @file = file
    @current_row = nil
  end

  def import
    process_csv do |level, parent|
      fields = fill_fields level, :parent_id => parent.try(:id)
      level.constantize.find_or_create_by_code fields
    end
  end

  def simulate
    process_csv do |level, parent|
      fields = fill_fields level, :parent => parent
      place = level.constantize.find_by_code fields[:code]
      return unless place.nil?

      level.constantize.new fields
    end
  end

  private

  def process_csv
    @places = {}

    CSV.foreach @file, :headers => :first_row, :skip_blanks => true do |row|
      @current_row = row
      @parent = nil

      Place.levels.each do |level|
        place = yield level, @parent

        return unless place && place.valid?
        @parent = place

        @places[place.code] = place
      end
    end

    @places.values
  end

  CSVIndexes = {
    "Province" => { :name => 0, :name_kh => 1, :code => 2 },
    "OD" => { :name => 3, :name_kh => 4, :code => 5 },
    "HealthCenter" => { :name => 6, :name_kh => 7, :code => 8 },
    "Village" => { :name => 9, :name_kh => 10, :code => 11, :lat => 12, :lng => 13 }
  }

  ColumnNames = {
    :name => 'name',
    :name_kh => 'name (khmer)',
    :code => 'code',
    :lat => 'latitude',
    :lng => 'longitude'
  }

  def fill_fields place_type, extensions
    fields_indexes = CSVIndexes[place_type]
    fields = fields_indexes.merge(fields_indexes) { |k, v| @current_row[v] }
    fields[:name_kh] unless fields[:name_kh].nil?
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
    place == "OD" ? "OD" : place.titleize
  end
end
