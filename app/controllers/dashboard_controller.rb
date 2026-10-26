class DashboardController < ApplicationController
  def index
    @patients = Current.user.patients
      .includes(care_plans: { recommendations: :check_ins })
      .order(:name)
  end
end
