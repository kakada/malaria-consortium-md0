module ThresholdsHelper

  PlaceHierarchy = [Place, Country, Province, OD, HealthCenter, Village]

  def render_threshold_table_cell threshold, column_type
    if PlaceHierarchy.index(column_type) <= PlaceHierarchy.index(threshold.place.class)
      threshold.place.get_parent(column_type).name
    elsif PlaceHierarchy.index(column_type) <= PlaceHierarchy.index(threshold.place_class.constantize)
      'All'
    else
      ''
    end
  end

  def hc_and_villages od, health_centers
    yield ['All health centers', "HealthCenter:#{od.id}"]
    yield ['All villages', "Village:#{od.id}"]
    health_centers.each do |hc|
      yield [hc.description, "HealthCenter:#{hc.id}"]
      yield ["- All villages in #{hc.description}", "Village:#{hc.id}"]
      hc.villages.to_a.sort {|x,y| x.name <=> y.name}.each do |village|
        yield ["- #{village.description}", "Village:#{village.id}"]
      end
    end
  end

end
