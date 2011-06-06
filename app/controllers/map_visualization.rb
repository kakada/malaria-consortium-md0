class MapVisualization
  def self.paginate_report(options = {})
    place = Place.find options[:id]
    Report.
      no_error.
      at_place(place).
      between_dates(options[:from], options[:to]).
      with_malaria_type(options[:type]).
      order('created_at desc').
      paginate :page => options[:page], :per_page => 10
  end

  def self.report_case_count(options = {})
    if options[:id].blank? || options[:id].to_i == 0
      place = Country.national
      reports = Report.no_error.between_dates(options[:from], options[:to]).with_malaria_type(options[:type])
      places = [place.as_json(:only => [:id, :name, :type, :lat, :lng]).merge('total' => reports.count)]
    else
      place = Place.find options[:id]
      sql = self.get_report_case_count_query place, options
      places = Place.connection.select_all(sql)
    end

    creteria = Creteria.new
    places.each { |place| creteria.add_record! place["name"], place["total"] }
    creteria.prepare!

    options = {:place => places, :cloud => creteria.cloud}
    options[:parent] = {:type => place.type, :id => place.id, :name => place.name} unless place.country?
    options
  end

  private

  def self.get_report_case_count_query place, options
    sub_reports = Report.no_error.between_dates(options[:from], options[:to]).with_malaria_type(options[:type])
    report_sub_table = " (#{sub_reports.to_sql}) AS report "

    sql = " SELECT top_places.*, count(report.id) as total FROM places top_places "
    sql += " LEFT JOIN #{report_sub_table} ON top_places.id = report.#{place.sub_place_class.foreign_key} "
    if place.village?
      sql += " where top_places.id = #{options[:id]} "
    else
      sql += " where top_places.parent_id = #{options[:id]} "
    end
    sql += " GROUP BY top_places.id ORDER BY total DESC "
    sql
  end
end
