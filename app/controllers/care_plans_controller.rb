class CarePlansController < ApplicationController
  before_action :set_patient, only: %i[ new create ]
  before_action :set_care_plan, only: %i[ show edit update ]

  def show
  end

  def new
    @care_plan = @patient.care_plans.new(start_date: Date.current)
    @care_plan.recommendations.build
  end

  def create
    @care_plan = @patient.care_plans.new(care_plan_params)
    if @care_plan.save
      redirect_to @care_plan, notice: "Care plan saved."
    else
      @care_plan.recommendations.build if @care_plan.recommendations.reject(&:marked_for_destruction?).empty?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @care_plan.update(care_plan_params)
      redirect_to @care_plan, notice: "Care plan updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_patient
      @patient = Current.user.patients.find(params[:patient_id])
    end

    def set_care_plan
      @care_plan = Current.user.care_plans.includes(recommendations: :check_ins).find(params[:id])
    end

    def care_plan_params
      params.require(:care_plan).permit(
        :start_date,
        recommendations_attributes: [ :id, :name, :dose, :times_per_day, :_destroy ]
      )
    end
end
