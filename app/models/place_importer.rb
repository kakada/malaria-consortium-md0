require 'csv'

class PlaceImporter
  
  def self.import file
    CSV.foreach(file, { :headers => :first_row, :skip_blanks => true }) do |row|
      
      province = Place.find_or_create :name => row[0], :name_kh => row[1], :code => row[2], 
                                      :place_type => Place::Province
      
      if province.valid?
        import_od province, row
      end
    end
  end

  private
  
  def self.import_od province, row
    
    od = Place.find_or_create :name => row[3], :name_kh => row[4], :code => row[5], :parent_id => province.id,
                              :place_type => Place::OD
    
    if od.valid?
      import_health_center od, row
    end
  end

  def self.import_health_center od, row
                    
    health_center = Place.find_or_create :code => row[9], :name => row[10], :name_kh => row[11],
                                          :parent_id => od.id, :place_type => Place::HealthCenter
    
    if health_center.valid?
      import_village health_center, row
    end
  end

  def self.import_village health_center, row
    
    Place.find_or_create :name => row[15], :name_kh => row[16], :code => row[17], :parent_id => health_center.id,
                          :place_type => Place::Village
  
  end
end