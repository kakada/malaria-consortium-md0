# encoding: UTF-8

require 'csv'

class PlaceImporter
  
  def initialize file
    @file = file
    @current_row = nil
  end
  
  def import
    process_csv do |level, parent|
      fields = fill_fields level, :parent_id => parent ? parent.id : nil
      level.constantize.find_or_create_by_code fields[:code], fields
    end
  end
  
  def simulate
    process_csv do |level, parent|
      fields = fill_fields level, :parent => parent
      
      place = level.constantize.find_by_code fields[:code]
      return nil unless place.nil?
      
      level.constantize.new fields
    end
  end
  
  private

  CSVIndexes = { 
                  "province_fields" => { :code => 2, :name => 0, :name_kh => 1 },
                  "od_fields" => { :code => 8, :name => 6, :name_kh => 7 },
                  "health_center_fields" => { :code => 9, :name => 10, :name_kh => 11 },
                  "village_fields" => { :code => 17, :name => 15, :name_kh => 16 }
                }
                
  def process_csv
     @places = {}

      CSV.foreach(@file, { :headers => :first_row, :skip_blanks => true }) do |row|
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
            
  def fill_fields place_type, extensions
    fields_indexes = CSVIndexes["#{place_type}Fields".underscore]
    fields = fields_indexes.merge(fields_indexes) { |k,v| @current_row[v] }
    fields[:name_kh] unless fields[:name_kh].nil?
    fields.merge!(extensions)
    fields
  end
end
