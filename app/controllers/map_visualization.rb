class MapVisualization
  def self.paginate_report attribute
    
    id    = attribute[:id]
    from  = attribute[:from]
    to    = attribute[:to]
    malaria_type  = attribute[:type]
    page  = attribute[:page]

    place = Place.find(id)
    conditions = self.get_paginate_conditions id, from, to, malaria_type, place.type
    reports = Report.paginate :page => page,
                              :per_page => 10 ,
                              :conditions => conditions,
                              :order => "created_at desc"
    reports
  end

  def self.report_case_count attribute

    id            = attribute[:id]
    from          = attribute[:from]
    to            = attribute[:to]
    malaria_type  = attribute[:type]

    if(id.blank?  || id.to_i == 0)
        total = Report.count :conditions =>["created_at between :from and :to AND #{self.get_marlaria_type_condition(malaria_type)} ", {:from => from, :to => to}]
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
        sql = self.get_report_case_count_query id , from , to , malaria_type , place.type

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

 private
  def self.get_paginate_conditions id, from, to, malaria_type, place_type
      conditions = nil  
      type_condition = self.get_marlaria_type_condition(malaria_type)

      if place_type == "Country"
         conditions = ["created_at between :from AND :to AND #{type_condition} ", {:from => from, :to => to} ]
      elsif place_type == "Province"
         conditions = ["created_at between :from AND :to AND province_id = :province_id AND #{type_condition} ", {
                  :from => from, :to => to, :province_id => id}]
      elsif place_type == "OD"
         conditions = ["created_at between :from AND :to AND od_id = :od_id AND #{type_condition} ",{
                  :from => from, :to => to, :od_id=> id}]
      elsif place_type == "HealthCenter"
         conditions = ["created_at between :from AND :to AND health_center_id = :health_center_id  AND #{type_condition}  ",{
                  :from => from, :to => to, :health_center_id => id}]
      elsif place_type == "Village"
         conditions = ["created_at between :from AND :to AND village_id = :village_id  AND #{type_condition} ",{
                  :from => from, :to => to, :village_id => id}]
      end
      conditions
  end



  def self.get_marlaria_type_condition(type)
    conditions = " 1 = 1 "
    if type == "Pf"
      conditions += " AND ( malaria_type = 'F' OR malaria_type = 'M' )"
    elsif type == "Pv"
      conditions += " AND ( malaria_type = 'V' )"
    elsif (type == "All")
      conditions += " AND ( malaria_type = 'F' OR malaria_type = 'M' OR malaria_type = 'V'  )"
    end
    conditions
  end

  def self.get_report_case_count_query id , from , to , malaria_type , place_type
    report_sub_table = " (SELECT * from reports WHERE created_at between '#{from}' AND '#{to}' AND #{self.get_marlaria_type_condition(malaria_type) }  ) AS report "

    if(place_type == "Country")
      sql = " SELECT province.*, count(report.id) as total FROM places province LEFT JOIN #{report_sub_table} " +
          " ON province.id = report.province_id  where province.parent_id = #{id} GROUP BY province.id ORDER BY total DESC "
    elsif(place_type == "Province")
      sql = " SELECT od.*, count(report.id) as total FROM places od LEFT JOIN #{report_sub_table}  " +
            " ON od.id = report.od_id WHERE  od.parent_id = #{id} GROUP BY od.id ORDER BY total DESC "
    elsif(place_type == "OD" )
      sql = " SELECT hc.*, count(report.id) as total FROM places hc LEFT JOIN #{report_sub_table}  " +
            " ON hc.id = report.health_center_id WHERE hc.parent_id = #{id} GROUP BY hc.id ORDER BY total DESC "
    elsif(place_type == "HealthCenter")
      sql = " SELECT village.*, count(report.id) as total FROM places village LEFT JOIN #{report_sub_table} " +
            " ON village.id = report.village_id WHERE village.parent_id = #{id} GROUP BY village.id ORDER BY total DESC "
    elsif(place_type == "Village")
      sql = " SELECT village.*, count(report.id) as total FROM places village LEFT JOIN #{report_sub_table}  " +
            " ON village.id = report.village_id WHERE village.id = #{id} GROUP BY village.id ORDER BY total DESC "
    end
    sql
  end

  

end