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

    f = counts["F"].nil? ? 0 : counts["F"]
    m = counts["M"].nil? ? 0 : counts["M"]
    v = counts["V"].nil? ? 0 : counts["V"]


    template_values = {
      :cases => counts.values.sum,
      :pf_cases => f + m,
      :pv_cases => v,
      :f_cases => f,
      :v_cases => v,
      :m_cases => m,
      :village => self.name
    }
    Setting[:aggregate_village_cases_template].apply(template_values)
  end

  def self.strip_code
    Village.all.each_with_index do |village,index|
      if !village.code.nil?
        code = village.code.strip_village_code
        if village.code !=code
          #p "#{index}: stripping code from #{village.code}  --> #{code}"
          village.code = code
          if village.save
            # p "save\n\n"
          else
            # p "failed to savesss"
          end
        end
        
      end
    end
  end

  
end
