require 'spec_helper'

describe ThresholdsHelper do

  before(:each) do
    @village = Village.make
    @hc = @village.parent
    @od = @hc.parent
    @province = @od.parent
  end

  it 'should return place name for upper levels' do
    th = Threshold.new :place => @od, :place_class => Village.name
    render_threshold_table_cell(th, Province).should == @province.name
  end

  it 'should return place name for same level' do
    th = Threshold.new :place => @od, :place_class => Village.name
    render_threshold_table_cell(th, OD).should == @od.name
  end

  it 'should return place name for same level defined in single place' do
    th = Threshold.new :place => @village, :place_class => Village.name
    render_threshold_table_cell(th, OD).should == @od.name
    render_threshold_table_cell(th, Village).should == @village.name
  end

  it 'should return All for place class different to place kind' do
    th = Threshold.new :place => @hc, :place_class => Village.name
    render_threshold_table_cell(th, Village).should == 'All'
  end

  it 'should return All for place class between place and place kind' do
    th = Threshold.new :place => @od, :place_class => Village.name
    render_threshold_table_cell(th, HealthCenter).should == 'All'
  end

  it 'should return empty string for place class below place class' do
    th = Threshold.new :place => @od, :place_class => HealthCenter.name
    render_threshold_table_cell(th, Village).should == ''
  end

end