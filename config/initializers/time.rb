class Time
  def self.last_week
    7.days.ago.at_beginning_of_day
  end
end
