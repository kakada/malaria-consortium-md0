require 'spec_helper'

describe PlaceImporter do
  it "should import" do
    file = File.join(File.dirname(__FILE__),"test.csv")
    PlaceImporter.import(file)

    Province.count.should == 2
    District.count.should == 3
    HealthCenter.count.should == 8
    Village.count.should == 51
    
    kralapeas = Village.find_by_code "02010304"
    kralapeas.name.should == "Krala Peas"
    kralapeas.name_kh.should == "RkLaBas"

    kralapeas.health_center.name.should == "Chheu Teal"
    kralapeas.health_center.name_kh.should == "eQITal"
    kralapeas.health_center.code.should == "020411"

    kralapeas.district.name.should == "Banan"
    kralapeas.district.name_kh.should == ")aNn"
    kralapeas.district.code.should == "0201"

    kralapeas.district.province.name.should == "Battambang"
    kralapeas.district.province.name_kh.should == ")at;dMbg"
    kralapeas.district.province.code.should == "02"




  end
end