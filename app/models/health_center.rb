class HealthCenter < Place
  alias_method :od, :parent
  delegate :province, :to => :od
  has_many :villages, :class_name => "Village", :foreign_key => "parent_id"

  def report_parser(user)
    HCReportParser.new user
  end

  def reports_since time
    Report.no_error.where(:village_id => Village.where(:parent_id => id)).where("created_at >= ?", time)
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
      :health_center => self.name
    }
    Setting[:aggregate_hc_cases_template].apply(template_values)
  end
end
