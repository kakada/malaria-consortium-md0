require "faster_csv"
class PlaceImporter
  
  def self.import file
    FasterCSV.foreach(file, { :headers => :first_row, :skip_blanks => true }) do |row|
      province_attr = {
        :name=>row[0],
        :name_kh => row[1],
        :code => row[2]
      }

      province =  Province.find_or_create(province_attr)
      if(province.valid?)
       import_district province, row
      end
    end
  end

  private
  
  def self.import_district province, row
    district_attr = {
           :name=>row[3],
           :name_kh => row[4],
           :code => row[5],
           :province_id =>province.id
         }
    district = District.find_or_create district_attr
    if(district.valid?)
      import_health_center district, row
    end
  end

  def self.import_health_center district, row
    health_center_attr = {
                     :code => row[9],
                     :name=>row[10],
                     :name_kh => row[11],
                     :district_id =>district.id
    }
    health_center = HealthCenter.find_or_create health_center_attr
    if(health_center.valid?)
      import_village district, health_center, row
    end
  end

  def self.import_village district, health_center, row
    village_attr = {
                       :name=>row[15],
                       :name_kh => row[16],
                       :code => row[17],
                       :district_id =>district.id,
                       :health_center_id =>health_center.id
      }
     village = Village.new(village_attr)
     village.save
  end
end