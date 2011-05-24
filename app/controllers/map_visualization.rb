class MapVisualization
  def self.paginate_report id , to ,from , page

    place = Place.find(id)
    conditions = []
    if(place.type == "Country")
       conditions = ["created_at between :from AND :to",{:from => from, :to => to}]
    elsif place.type == "Province"
       conditions = ["created_at between :from AND :to AND province_id = :province_id",{
                :from => from, :to => to, :province_id => place.id}]
    elsif place.type == "OD"
       conditions = ["created_at between :from AND :to AND od_id = :od_id",{
                :from => from, :to => to, :od_id=> place.id}]
    elsif place.type == "HealthCenter"
       conditions = ["created_at between :from AND :to AND health_center_id = :health_center_id",{
                :from => from, :to => to, :health_center_id => place.id}]
    elsif place.type == "Village"
       conditions = ["created_at between :from AND :to AND village_id = :village_id ",{
                :from => from, :to => to, :village_id => place.id}]

    end

    reports = Report.paginate :page => page,
                               :per_page => 10 ,
                               :conditions => conditions,
                               :order => "created_at desc"
    reports
  end

  def self.report_case_count(id, from , to)
    if(id.blank?  || id.to_i == 0)
        total = Report.count :conditions =>["created_at between :from and :to", {:from => from, :to => to}]
        country = Place.find_by_type "Country"
        places = [{
                    "name" => country.name,
                    "id" => country.id,
                    "type" => country.type,
                    "parent_id" => country.parent_id,
                    "lat" => country.lat,
                    "lng" => country.lng
                  }]
        creteria = Creteria.new

        places.each do |place|
          place["total"] = total
          creteria.add_record!(place["name"], place["total"])
        end
        creteria.prepare!
        clouds = creteria.cloud
        @result = {:place=>places, :cloud=>clouds }
      else
        place = Place.find(id)
        if(place.type == "Country")
          sql = " SELECT province.*, count(report.id) as total FROM places province LEFT JOIN (SELECT * from reports WHERE created_at between '#{from}' AND '#{to}') AS report " +
              " ON province.id = report.province_id  where province.parent_id = #{place.id} GROUP BY province.id ORDER BY total DESC "
        elsif(place.type == "Province")
          sql = " SELECT od.*, count(report.id) as total FROM places od LEFT JOIN (SELECT * from reports WHERE created_at between '#{from}' AND '#{to}') AS  report " +
                " ON od.id = report.od_id WHERE  od.parent_id = #{place.id} GROUP BY od.id ORDER BY total DESC "
        elsif(place.type == "OD" )
          sql = " SELECT hc.*, count(report.id) as total FROM places hc LEFT JOIN (SELECT * from reports WHERE created_at between '#{from}' AND '#{to}') AS report " +
                " ON hc.id = report.health_center_id WHERE hc.parent_id = #{place.id} GROUP BY hc.id ORDER BY total DESC "
        elsif(place.type == "HealthCenter")
          sql = " SELECT village.*, count(report.id) as total FROM places village LEFT JOIN (SELECT * from reports WHERE created_at between '#{from}' AND '#{to}') AS  report " +
                " ON village.id = report.village_id WHERE village.parent_id = #{place.id} GROUP BY village.id ORDER BY total DESC "
        elsif(place.type == "Village")
          sql = " SELECT village.*, count(report.id) as total FROM places village LEFT JOIN (SELECT * from reports WHERE created_at between '#{from}' AND '#{to}') AS report " +
                " ON village.id = report.village_id WHERE village.id = #{place.id} GROUP BY village.id ORDER BY total DESC "
        end

        places = Place.connection.select_all(sql)
        creteria = Creteria.new
        places.each do |place|
          creteria.add_record!(place["name"], place["total"])
        end

        creteria.prepare!
        clouds = creteria.cloud
        @result =  {:place =>places, :cloud=> clouds, :parent => {:type=>place.type,:id=>place.id,:name=>place.name} }

    end
    @result
  end

end