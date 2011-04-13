# encoding: UTF-8

require 'spec_helper'

describe PlaceImporter do
  it "should import" do
    file = File.join(File.dirname(__FILE__),"test.csv")
    PlaceImporter.import(file)

    Place.provinces.count.should == 2
    Place.ods.count.should == 3
    Place.health_centers.count.should == 8
    Place.villages.count.should == 51
    
    kralapeas = Place.find_by_code "2010104"
    kralapeas.name.should == "Svay Bei Daeum"
    kralapeas.name_kh.should == "sVaybIedIm"

    kralapeas.health_center.name.should == "Kantueu II"
    kralapeas.health_center.name_kh.should == "kenÞÓ 2"
    kralapeas.health_center.code.should == "20412"

    kralapeas.od.name.should == "Banan"
    kralapeas.od.name_kh.should == ")aNn"
    kralapeas.od.code.should == "201"

    kralapeas.province.name.should == "Battambang"
    kralapeas.province.name_kh.should == ")at;dMbg"
    kralapeas.province.code.should == "2"
  end
end
