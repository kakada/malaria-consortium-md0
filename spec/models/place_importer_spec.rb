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
    kralapeas.health_center.name_kh.force_encoding('utf-8').should == "kenÞÓ 2"
    kralapeas.health_center.code.should == "20412"

    kralapeas.od.name.should == "Battambang"
    kralapeas.od.name_kh.should == ")at;dMbg"
    kralapeas.od.code.should == "204"

    kralapeas.province.name.should == "Battambang"
    kralapeas.province.name_kh.should == ")at;dMbg"
    kralapeas.province.code.should == "2"
  end

  it "should simulate" do
    file = File.join(File.dirname(__FILE__),"test.csv")
    importer = PlaceImporter.new file

    places = importer.simulate

    provinces = places.select {|place| place.is_a? Province}
    ods = places.select {|place| place.is_a? OD}
    health_centers = places.select {|place| place.is_a? HealthCenter}
    villages = places.select {|place| place.is_a? Village}

    provinces.map(&:name).should =~ ["Battambang", "Banteay Meanchey"]
    ods.map(&:name).should =~ ["Battambang", "Ou Chrov", "Thma Puok"]
    health_centers.count.should == 8
    villages.count.should == 51

    kralapeas = places.select {|place| place.code == "2010104"}
    kralapeas = kralapeas.first
    kralapeas.name.should == "Svay Bei Daeum"
    kralapeas.name_kh.should == "sVaybIedIm"

    kralapeas.health_center.name.should == "Kantueu II"
    kralapeas.health_center.name_kh.force_encoding('utf-8').should == "kenÞÓ 2"
    kralapeas.health_center.code.should == "20412"

    kralapeas.od.name.should == "Battambang"
    kralapeas.od.name_kh.should == ")at;dMbg"
    kralapeas.od.code.should == "204"

    kralapeas.province.name.should == "Battambang"
    kralapeas.province.name_kh.should == ")at;dMbg"
    kralapeas.province.code.should == "2"

    Place.count.should == 0
  end

  it "should not show already existent places" do
    file = File.join(File.dirname(__FILE__),"test.csv")
    importer = PlaceImporter.new file
    importer.import

    new_simulation_result = importer.simulate
    new_simulation_result.should eq([])
  end

  it "returns csv column headers" do
    headers = PlaceImporter.column_headers
    headers.should eq(['Province name', 'Province name (khmer)', 'Province code',
                       'OD name', 'OD name (khmer)', 'OD code',
                       'Health Center name', 'Health Center name (khmer)', 'Health Center code',
                       'Village name', 'Village name (khmer)', 'Village code', 'Village latitude', 'Village longitude'])
  end
end
