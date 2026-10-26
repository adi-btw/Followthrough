require "test_helper"

class PatientCheckInsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @patient = @user.patients.create!(name: "Casey Nguyen")
    @other = @user.patients.create!(name: "Other Person")
    @plan = @patient.care_plans.create!(
      start_date: Date.current,
      recommendations_attributes: [
        { name: "Vitamin D", dose: "1000 IU", times_per_day: 1 },
        { name: "Magnesium", dose: "200 mg", times_per_day: 2 }
      ]
    )
    @other_plan = @other.care_plans.create!(
      start_date: Date.current,
      recommendations_attributes: [ { name: "Secret Zinc", dose: "15 mg", times_per_day: 1 } ]
    )
  end

  test "public page needs no login and lists only this plan" do
    get patient_check_in_path(@plan.check_in_token)

    assert_response :success
    assert_match "Casey Nguyen", response.body
    assert_match "Vitamin D", response.body
    assert_match "Magnesium", response.body
    assert_match "Mark morning", response.body
    assert_match "Mark evening", response.body
    assert_no_match "Other Person", response.body
    assert_no_match "Secret Zinc", response.body
    assert_no_match @other_plan.check_in_token, response.body
  end

  test "visitor can mark one dose and adherence counts that slot" do
    magnesium = @plan.recommendations.find_by!(name: "Magnesium")

    assert_equal 0, @plan.adherence.taken_doses

    post patient_check_in_path(@plan.check_in_token), params: {
      recommendation_id: magnesium.id,
      slot: "morning",
      taken: "1"
    }

    assert_redirected_to patient_check_in_path(@plan.check_in_token)
    follow_redirect!
    assert_response :success
    assert_match "Morning taken", response.body
    assert_match "Mark evening", response.body

    @plan.reload
    assert_equal 1, @plan.adherence.taken_doses
    assert_equal 3, @plan.adherence.expected_doses
    assert_equal 33, @plan.adherence.percentage
  end

  test "cannot mark a supplement from another plan" do
    other_recommendation = @other_plan.recommendations.sole

    post patient_check_in_path(@plan.check_in_token), params: {
      recommendation_id: other_recommendation.id,
      slot: "morning",
      taken: "1"
    }

    assert_response :not_found
    assert_equal 0, other_recommendation.check_ins.where(taken: true).count
  end

  test "unknown token is not found" do
    get patient_check_in_path("notarealtoken")

    assert_response :not_found
  end

  test "care plan page still requires login" do
    get care_plan_path(@plan)

    assert_redirected_to new_session_path
  end
end
