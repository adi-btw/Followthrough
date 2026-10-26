require "test_helper"

class AdherenceTest < ActiveSupport::TestCase
  setup do
    @on = Date.new(2026, 10, 26)
    @user = User.create!(email_address: "adherence@example.com", password: "password")
    @patient = @user.patients.create!(name: "Test Patient")
  end

  test "all taken over the window is 100 percent" do
    plan = plan_with(start_date: @on - 30, times_per_day: 1)
    window.each { |day| check_in(plan, day, taken: true) }

    adherence = Adherence.for(plan, as_of: @on)

    assert_equal 7, adherence.expected_doses
    assert_equal 7, adherence.taken_doses
    assert_equal 100, adherence.percentage
    assert_not adherence.needs_follow_up?
  end

  test "none taken is 0 percent" do
    plan = plan_with(start_date: @on - 30, times_per_day: 1)

    adherence = Adherence.for(plan, as_of: @on)

    assert_equal 7, adherence.expected_doses
    assert_equal 0, adherence.taken_doses
    assert_equal 0, adherence.percentage
    assert adherence.needs_follow_up?
  end

  test "plan started mid window only counts active days" do
    plan = plan_with(start_date: @on - 2, times_per_day: 1)
    check_in(plan, @on - 6, taken: true)
    (@on - 2..@on).each { |day| check_in(plan, day, taken: true) }

    adherence = Adherence.for(plan, as_of: @on)

    assert_equal 3, adherence.expected_doses
    assert_equal 3, adherence.taken_doses
    assert_equal 100, adherence.percentage
  end

  test "twice daily with one slot taken is 50 percent for that line" do
    plan = plan_with(start_date: @on - 30, times_per_day: 2, name: "Twice daily")
    window.each do |day|
      check_in(plan, day, taken: true, slot: "morning")
      check_in(plan, day, taken: false, slot: "evening")
    end

    adherence = Adherence.for(plan, as_of: @on)

    assert_equal 14, adherence.expected_doses
    assert_equal 7, adherence.taken_doses
    assert_equal 50, adherence.percentage
    assert_not adherence.needs_follow_up?
  end

  test "twice daily with both slots taken is twice the doses of once daily" do
    once = plan_with(start_date: @on - 30, times_per_day: 1, name: "Once daily")
    twice = plan_with(start_date: @on - 30, times_per_day: 2, name: "Twice daily")
    window.each do |day|
      check_in(once, day, taken: true, slot: "morning")
      check_in(twice, day, taken: true, slot: "morning")
      check_in(twice, day, taken: true, slot: "evening")
    end

    once_adherence = Adherence.for(once, as_of: @on)
    twice_adherence = Adherence.for(twice, as_of: @on)

    assert_equal 7, once_adherence.expected_doses
    assert_equal 7, once_adherence.taken_doses
    assert_equal 100, once_adherence.percentage

    assert_equal 14, twice_adherence.expected_doses
    assert_equal 14, twice_adherence.taken_doses
    assert_equal 100, twice_adherence.percentage
  end

  private
    def window
      (@on - 6)..@on
    end

    def plan_with(start_date:, times_per_day:, name: "Vitamin D")
      @patient.care_plans.create!(
        start_date: start_date,
        recommendations_attributes: [ { name: name, dose: "1 capsule", times_per_day: times_per_day } ]
      )
    end

    def check_in(plan, day, taken:, slot: "morning")
      plan.recommendations.first.check_ins.create!(taken_on: day, taken: taken, slot: slot)
    end
end
