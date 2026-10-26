module ApplicationHelper
  def schedule_label(times_per_day)
    times_per_day.to_i == 1 ? "Once a day" : "Twice a day"
  end

  def adherence_text(adherence)
    return "Not started" if adherence.percentage.nil?

    "#{adherence.percentage}%"
  end

  def slot_label(slot)
    slot.to_s == "evening" ? "Evening" : "Morning"
  end

  def day_summary(recommendation, date, start_date)
    return [ "before", "—" ] if date < start_date

    taken = recommendation.slots.count { |slot| recommendation.dose_taken_on?(date, slot) }
    total = recommendation.slots.size
    state = if taken == total
      "taken"
    elsif taken.zero?
      "missed"
    else
      "partial"
    end
    mark = total == 1 ? (taken.positive? ? "Yes" : "No") : "#{taken}/#{total}"
    [ state, mark ]
  end
end
