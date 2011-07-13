class Village < Place
  alias_method :health_center, :parent
  delegate :od, :to => :health_center
  delegate :province, :to => :od

  def report_parser(user)
    VMWReportParser.new user
  end

  def reports_since time
    Report.no_error.not_ignored.where("created_at >= ? AND village_id = ?", time, id)
  end

  def count_reports_since time
    reports_since(time).count
  end

  def reports_reached_threshold(threshold)
    count_reports_since(Time.last_week) >= threshold.value
  end

  def aggregate_report time
    counts = reports_since(time).group(:malaria_type).count
    template_values = {
      :cases => counts.values.sum,
      :f_cases => counts['F'] || 0,
      :v_cases => counts['V'] || 0,
      :m_cases => counts['M'] || 0,
      :village => self.name
    }
    Setting[:aggregate_village_cases_template].apply(template_values)
  end

  def self.strip_code
    Village.all.each do |village|
      if !village.code.nil?
        code = village.code[0,8]
        if village.code !=code
          p "stripping code from #{village.code}  --> #{code}"
          village.code = code
          village.save
          puts "done\n\n"
        end
        
      end
    end
  end

end
