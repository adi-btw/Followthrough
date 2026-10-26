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
    ((@on - 6)..@on).each do |day|
      @steady.recommendations.first.check_ins.create!(taken_on: day, taken: true)
    end
  end

  test "flags plans under 50 percent and clears the others" do
    @steady.update!(needs_follow_up: true)

    FollowUpJob.perform_now(@on)

    assert @low.reload.needs_follow_up
    assert_not @steady.reload.needs_follow_up
  end
end
