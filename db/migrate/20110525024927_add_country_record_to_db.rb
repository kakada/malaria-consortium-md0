class AddCountryRecordToDb < ActiveRecord::Migration
  def self.up
    country = Country.new :name =>"National", :code => 85523 , 
                          :lat => 12.71536762877211, :lng => 104.8974609375
    country.save!
    STDOUT.write ("Saved country")
    
    provinces  = Place.find_all_by_type "Province"
    
    provinces.each_with_index do |province,index|
      province.parent_id = country.id
      province.save
      STDOUT.write "#{index}/Province: #{province.name} saved\r"
    end
  end

  def self.down
  end
end