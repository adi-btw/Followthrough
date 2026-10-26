require "test_helper"

class RecommendationTest < ActiveSupport::TestCase
  setup do
    user = User.create!(email_address: "recommendations@example.com", password: "password")
    patient = user.patients.create!(name: "Case Patient")
    @plan = patient.care_plans.create!(
      start_date: Date.new(2026, 10, 1),
      recommendations_attributes: [ { name: "Placeholder", dose: "1 capsule", times_per_day: 1 } ]
    )
  end

  test "requires a name and a dose" do
    recommendation = @plan.recommendations.new(times_per_day: 1)

    assert_not recommendation.valid?
    assert_includes recommendation.errors[:name], "can't be blank"
    assert_includes recommendation.errors[:dose], "can't be blank"
  end

  test "times_per_day must be 1 or 2" do
    recommendation = @plan.recommendations.new(name: "Zinc", dose: "15 mg", times_per_day: 3)

    assert_not recommendation.valid?
    assert_includes recommendation.errors[:times_per_day], "must be 1 or 2"

    recommendation.times_per_day = 0
    assert_not recommendation.valid?

    recommendation.times_per_day = 1
    assert recommendation.valid?

    recommendation.times_per_day = 2
    assert recommendation.valid?
  end
end
