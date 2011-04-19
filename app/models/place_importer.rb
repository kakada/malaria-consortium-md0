require 'csv'

class PlaceImporter
  
  def initialize file
    @file = file
    @current_row = nil
  end
  
  def import
    CSV.foreach(@file, { :headers => :first_row, :skip_blanks => true }) do |row|
      @current_row = row
      @parent_id = nil
      
      Place.levels.each do |level|
        place = find_or_create_from_csv level, @parent_id
        return unless place.valid?
        
        @parent_id = place.id
      end
    end
  end
  
  private

  CSVIndexes = { 
                  "province_fields" => { :code => 2, :name => 0, :name_kh => 1 },
                  "od_fields" => { :code => 8, :name => 6, :name_kh => 7 },
                  "health_center_fields" => { :code => 9, :name => 10, :name_kh => 11 },
                  "village_fields" => { :code => 17, :name => 15, :name_kh => 16 }
                }
                
  def find_or_create_from_csv place_type, parent_id = nil
    fields_indexes = CSVIndexes["#{place_type}Fields".underscore]
    
    fields = fields_indexes.merge(fields_indexes) { |k,v| @current_row[v] }
    fields[:parent_id] = parent_id
    
    place_type.constantize.find_or_create_by_code fields[:code], fields
  end
end
