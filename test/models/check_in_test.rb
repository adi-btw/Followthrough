require "test_helper"

class CheckInTest < ActiveSupport::TestCase
  setup do
    user = User.create!(email_address: "checkins@example.com", password: "password")
    patient = user.patients.create!(name: "Slot Patient")
    @plan = patient.care_plans.create!(
      start_date: Date.new(2026, 10, 1),
      recommendations_attributes: [ { name: "Placeholder", dose: "1 capsule", times_per_day: 1 } ]
    )
  end

  test "a care plan generates a check-in token" do
    assert @plan.check_in_token.present?
  end

  test "morning and evening can both exist on the same day" do
    recommendation = recommendation_with(times_per_day: 2)
    day = Date.new(2026, 10, 26)

    morning = recommendation.check_ins.create!(taken_on: day, slot: "morning", taken: true)
    evening = recommendation.check_ins.create!(taken_on: day, slot: "evening", taken: false)

    assert morning.persisted?
    assert evening.persisted?
  end

  test "rejects a duplicate slot on the same day" do
    recommendation = recommendation_with(times_per_day: 2)
    day = Date.new(2026, 10, 26)
    recommendation.check_ins.create!(taken_on: day, slot: "morning", taken: true)
    duplicate = recommendation.check_ins.build(taken_on: day, slot: "morning", taken: false)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:taken_on], "has already been taken"
  end

  test "rejects an evening slot on a once-daily supplement" do
    recommendation = recommendation_with(times_per_day: 1)
    check_in = recommendation.check_ins.build(taken_on: Date.new(2026, 10, 26), slot: "evening", taken: true)

    assert_not check_in.valid?
    assert_includes check_in.errors[:slot], "is not scheduled for this supplement"
  end

  private
    def recommendation_with(times_per_day:)
      @plan.recommendations.create!(name: "Omega-3", dose: "1000 mg", times_per_day: times_per_day)
    end
end
