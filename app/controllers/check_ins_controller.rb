class CheckInsController < ApplicationController
  before_action :set_care_plan

  def create
    recommendation = @care_plan.recommendations.find(params[:recommendation_id])
    saved = recommendation.record_dose!(
      slot: params[:slot],
      taken: ActiveModel::Type::Boolean.new.cast(params[:taken])
    )

    if saved
      redirect_to @care_plan, notice: "Dose saved.", status: :see_other
    else
      redirect_to @care_plan, alert: "That dose is not scheduled.", status: :see_other
    end
  end

  private
    def set_care_plan
      @care_plan = Current.user.care_plans.find(params[:care_plan_id])
    end
end
