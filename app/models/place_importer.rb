require 'csv'

class PlaceImporter

  def self.import file
    CSV.foreach(file, { :headers => :first_row, :skip_blanks => true }) do |row|
      province = Province.find_or_create_by_code row[2], :name => row[0], :name_kh => row[1]
      import_od province, row if province.valid?
    end
  end

  private

  def self.import_od province, row
    od = OD.find_or_create_by_code row[5], :name => row[3], :name_kh => row[4], :parent_id => province.id
    import_health_center od, row if od.valid?
  end

  def self.import_health_center od, row
    health_center = HealthCenter.find_or_create_by_code row[9], :name => row[10], :name_kh => row[11], :parent_id => od.id
    import_village health_center, row if health_center.valid?
  end

  def self.import_village health_center, row
    Village.find_or_create_by_code row[17], :name => row[15], :name_kh => row[16], :parent_id => health_center.id
  end
end
