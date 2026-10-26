class CheckInsController < ApplicationController
  before_action :set_care_plan

  def create
    recommendation = @care_plan.recommendations.find(params[:recommendation_id])
    check_in = recommendation.check_ins.find_or_initialize_by(taken_on: Date.current)
    check_in.taken = ActiveModel::Type::Boolean.new.cast(params[:taken])
    check_in.save!
    redirect_to @care_plan, notice: "Today's check-in saved.", status: :see_other
  end

  private
    def set_care_plan
      @care_plan = Current.user.care_plans.find(params[:care_plan_id])
    end
end
