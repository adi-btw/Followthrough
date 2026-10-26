require "test_helper"

class CarePlansControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "signed-in practitioner creates a patient and a plan and sees it" do
    sign_in_as @user

    assert_difference -> { @user.patients.count }, 1 do
      post patients_path, params: { patient: { name: "Avery Quinn" } }
    end

    patient = @user.patients.find_by!(name: "Avery Quinn")
    assert_redirected_to patient_path(patient)

    assert_difference -> { patient.care_plans.count }, 1 do
      post patient_care_plans_path(patient), params: {
        care_plan: {
          start_date: Date.current,
          recommendations_attributes: {
            "0" => { name: "Vitamin D", dose: "1000 IU", times_per_day: 1 }
          }
        }
      }
    end

    plan = patient.care_plans.order(:id).last
    assert_redirected_to care_plan_path(plan)

    follow_redirect!
    assert_response :success
    assert_match "Avery Quinn", response.body
    assert_match "Vitamin D", response.body
    assert_match "1000 IU", response.body
    assert_match "/check-in/#{plan.check_in_token}", response.body
  end

  test "practitioner records one slot and adherence counts that dose" do
    sign_in_as @user
    patient = @user.patients.create!(name: "Avery Quinn")
    plan = patient.care_plans.create!(
      start_date: Date.current,
      recommendations_attributes: [ { name: "Magnesium", dose: "200 mg", times_per_day: 2 } ]
    )
    recommendation = plan.recommendations.sole

    post care_plan_check_ins_path(plan), params: {
      recommendation_id: recommendation.id,
      slot: "evening",
      taken: "1"
    }

    assert_redirected_to care_plan_path(plan)
    follow_redirect!
    assert_response :success
    assert_match "Evening taken", response.body
    assert_match "Mark morning", response.body

    plan.reload
    assert_equal 1, plan.adherence.taken_doses
    assert_equal 2, plan.adherence.expected_doses
    assert_equal 50, plan.adherence.percentage
  end
end
