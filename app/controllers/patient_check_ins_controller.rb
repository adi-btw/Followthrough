class PatientCheckInsController < ApplicationController
  allow_unauthenticated_access

  before_action :set_care_plan

  def show
  end

  def create
    recommendation = @care_plan.recommendations.find(params[:recommendation_id])
    saved = recommendation.record_dose!(
      slot: params[:slot],
      taken: ActiveModel::Type::Boolean.new.cast(params[:taken])
    )

    if saved
      redirect_to patient_check_in_path(@care_plan.check_in_token), notice: "Dose saved.", status: :see_other
    else
      redirect_to patient_check_in_path(@care_plan.check_in_token), alert: "That dose is not scheduled.", status: :see_other
    end
  end

  private
    def set_care_plan
      @care_plan = CarePlan.includes(:patient, recommendations: :check_ins).find_by!(check_in_token: params[:token])
    end
end
