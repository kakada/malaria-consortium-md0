# encoding: UTF-8

require 'spec_helper'

describe PlaceImporter do
  it "should import" do
    file = File.join(File.dirname(__FILE__),"test.csv")
    PlaceImporter.import(file)

    Province.count.should == 2
    District.count.should == 3
    HealthCenter.count.should == 8
    Village.count.should == 51
    
    kralapeas = Village.find_by_code "2010104"
    kralapeas.name.should == "Svay Bei Daeum"
    kralapeas.name_kh.should == "sVaybIedIm"

    kralapeas.health_center.name.should == "Kantueu II"
    kralapeas.health_center.name_kh.should == "kenÞÓ 2"
    kralapeas.health_center.code.should == "20412"

    kralapeas.district.name.should == "Banan"
    kralapeas.district.name_kh.should == ")aNn"
    kralapeas.district.code.should == "201"

    kralapeas.district.province.name.should == "Battambang"
    kralapeas.district.province.name_kh.should == ")at;dMbg"
    kralapeas.district.province.code.should == "2"
  end
end
