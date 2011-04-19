# encoding: UTF-8

require 'spec_helper'

describe PlaceImporter do
  it "should import" do
    file = File.join(File.dirname(__FILE__),"test.csv")
    importer = PlaceImporter.new file
    
    importer.import

    Province.all.map(&:name).should =~ ["Battambang", "Banteay Meanchey"]
    OD.all.map(&:name).should =~ ["Battambang", "Ou Chrov", "Thma Puok"]
    HealthCenter.count.should == 8
    Village.count.should == 51

    kralapeas = Place.find_by_code "2010104"
    kralapeas.name.should == "Svay Bei Daeum"
    kralapeas.name_kh.should == "sVaybIedIm"

    kralapeas.health_center.name.should == "Kantueu II"
    kralapeas.health_center.name_kh.should == "kenÞÓ 2"
    kralapeas.health_center.code.should == "20412"

    kralapeas.od.name.should == "Battambang"
    kralapeas.od.name_kh.should == ")at;dMbg"
    kralapeas.od.code.should == "204"

    kralapeas.province.name.should == "Battambang"
    kralapeas.province.name_kh.should == ")at;dMbg"
    kralapeas.province.code.should == "2"
  end
end
