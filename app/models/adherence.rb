# 7-day adherence for one care plan.
#
# Expected doses are times_per_day times the days the plan has been active
# inside the window (as_of and the six days before it), summed across
# recommendations. Each scheduled slot is one dose. A taken check-in counts
# as one dose for that slot. A missing or unmarked slot counts as zero.
class Adherence
  WINDOW_DAYS = 7

  def self.for(care_plan, as_of: Date.current)
    new(
      start_date: care_plan.start_date,
      recommendations: care_plan.recommendations,
      as_of: as_of
    )
  end

  def initialize(start_date:, recommendations:, as_of: Date.current)
    @start_date = start_date.to_date
    @recommendations = recommendations
    @as_of = as_of.to_date
  end

  def expected_doses
    @recommendations.sum { |recommendation| recommendation.times_per_day.to_i * active_day_count }
  end

  def taken_doses
    @recommendations.sum { |recommendation| taken_slots(recommendation) }
  end

  def rate
    return 0.0 if expected_doses.zero?

    taken_doses.to_f / expected_doses
  end

  def percentage
    return nil if expected_doses.zero?

    (rate * 100).round
  end

  def needs_follow_up?
    percentage.present? && percentage < 50
  end

  private
    def active_day_count
      return 0 if @start_date > @as_of

      first_day = [ @start_date, window_start ].max
      (@as_of - first_day).to_i + 1
    end

    def window_start
      @as_of - (WINDOW_DAYS - 1)
    end

    def taken_slots(recommendation)
      allowed = recommendation.slots
      rows = recommendation.check_ins.respond_to?(:to_a) ? recommendation.check_ins.to_a : recommendation.check_ins
      rows.count { |check_in| dose_taken?(check_in) && allowed.include?(check_in.slot) }
    end

    def dose_taken?(check_in)
      return false unless check_in.taken
      return false if check_in.taken_on.blank?

      date = check_in.taken_on.to_date
      date >= @start_date && date >= window_start && date <= @as_of
    end
end
