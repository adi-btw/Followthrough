class PatientsController < ApplicationController
  before_action :set_patient, only: %i[ show edit update ]

  def index
    @patients = Current.user.patients.includes(:care_plans).order(:name)
  end

  def show
    @care_plans = @patient.care_plans.includes(recommendations: :check_ins).order(start_date: :desc)
  end

  def new
    @patient = Current.user.patients.new
  end

  def create
    @patient = Current.user.patients.new(patient_params)
    if @patient.save
      redirect_to @patient, notice: "Patient added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @patient.update(patient_params)
      redirect_to @patient, notice: "Patient updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_patient
      @patient = Current.user.patients.find(params[:id])
    end

    def patient_params
      params.require(:patient).permit(:name)
    end
end
