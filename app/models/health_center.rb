class HealthCenter < Place
  alias_method :od, :parent
  delegate :province, :to => :od
  has_many :villages, :class_name => "Village", :foreign_key => "parent_id"
  has_many :referral_reports, :class_name => "Referral::Report"

  def report_parser(user)
    HCReportParser.new user
  end

  def reports_since time
    Report.no_error.not_ignored.where(:village_id => Village.where(:parent_id => id)).where("created_at >= ?", time)
  end

  def count_reports_since time
    reports_since(time).count
  end

  def reports_reached_threshold(threshold)
    count_reports_since(Time.last_week) >= threshold.value
  end
  
  def aggregate_report time
    counts = reports_since(time).group(:malaria_type).count
    f = counts["F"].nil? ? 0 : counts["F"]
    m = counts["M"].nil? ? 0 : counts["M"]
    v = counts["V"].nil? ? 0 : counts["V"]
    
    template_values = {
      :cases => counts.values.sum,
      :pf_cases => f+m,
      :pv_cases => v,
      :f_cases => f,
      :v_cases => v,
      :m_cases => m,
      :health_center => self.name
    }
    Setting[:aggregate_hc_cases_template].apply(template_values)
  end
end
