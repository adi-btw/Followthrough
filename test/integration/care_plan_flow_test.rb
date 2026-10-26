require "test_helper"

class CarePlanFlowTest < ActionDispatch::IntegrationTest
  test "signed-in practitioner creates a patient and a plan and sees it on the plan page" do
    sign_in_as users(:one)

    assert_difference -> { users(:one).patients.count }, 1 do
      post patients_path, params: { patient: { name: "Riley Chen" } }
    end

    patient = users(:one).patients.find_by!(name: "Riley Chen")
    assert_redirected_to patient_path(patient)

    assert_difference -> { patient.care_plans.count }, 1 do
      post patient_care_plans_path(patient), params: {
        care_plan: {
          start_date: Date.current,
          recommendations_attributes: {
            "0" => { name: "Vitamin D", dose: "1000 IU", times_per_day: "1" }
          }
        }
      }
    end

    plan = patient.care_plans.sole
    assert_redirected_to care_plan_path(plan)

    get care_plan_path(plan)
    assert_response :success
    assert_match "Riley Chen", response.body
    assert_match "Vitamin D", response.body
    assert_match "1000 IU", response.body
    assert_match "7-day adherence", response.body
    assert_match "0%", response.body
  end
end
