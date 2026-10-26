require "test_helper"

class FollowUpJobTest < ActiveSupport::TestCase
  setup do
    @on = Date.new(2026, 10, 26)
    user = User.create!(email_address: "followup@example.com", password: "password")
    patient = user.patients.create!(name: "Follow Up Patient")
    @low = patient.care_plans.create!(
      start_date: @on - 30,
      recommendations_attributes: [ { name: "Iron", dose: "18 mg", times_per_day: 1 } ]
    )
    @steady = patient.care_plans.create!(
      start_date: @on - 30,
      recommendations_attributes: [ { name: "Vitamin C", dose: "500 mg", times_per_day: 1 } ]
    )
    @partial = patient.care_plans.create!(
      start_date: @on - 30,
      recommendations_attributes: [ { name: "Probiotic", dose: "1 capsule", times_per_day: 2 } ]
    )
    ((@on - 6)..@on).each do |day|
      @steady.recommendations.first.check_ins.create!(taken_on: day, slot: "morning", taken: true)
    end
    # Six mornings of a twice-daily plan is 6/14. Counting the day as both
    # doses would be 12/14 and would not flag this plan.
    ((@on - 5)..@on).each do |day|
      @partial.recommendations.first.check_ins.create!(taken_on: day, slot: "morning", taken: true)
    end
  end

  test "flags plans under 50 percent and clears the others" do
    @steady.update!(needs_follow_up: true)
    @partial.update!(needs_follow_up: false)

    FollowUpJob.perform_now(@on)

    assert @low.reload.needs_follow_up
    assert @partial.reload.needs_follow_up
    assert_not @steady.reload.needs_follow_up
  end
end
