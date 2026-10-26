module ApplicationHelper
  def schedule_label(times_per_day)
    times_per_day.to_i == 1 ? "Once a day" : "Twice a day"
  end

  def adherence_text(adherence)
    return "Not started" if adherence.percentage.nil?

    "#{adherence.percentage}%"
  end
end
