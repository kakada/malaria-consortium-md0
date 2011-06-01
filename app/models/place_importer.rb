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
    "Province" => { :code => 2, :name => 0, :name_kh => 1 },
    "OD" => { :code => 8, :name => 6, :name_kh => 7 },
    "HealthCenter" => { :code => 9, :name => 10, :name_kh => 11 },
    "Village" => { :code => 17, :name => 15, :name_kh => 16 }
  }

  def fill_fields place_type, extensions
    fields_indexes = CSVIndexes[place_type]
    fields = fields_indexes.merge(fields_indexes) { |k,v| @current_row[v] }
    fields[:name_kh] unless fields[:name_kh].nil?
    fields.merge!(extensions)
    fields
  end
end
