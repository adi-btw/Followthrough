Rails.application.routes.draw do
  get "check-in/:token", to: "patient_check_ins#show", as: :patient_check_in, constraints: { token: /[A-Za-z0-9]+/ }
  post "check-in/:token", to: "patient_check_ins#create", constraints: { token: /[A-Za-z0-9]+/ }

  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[ new create ]
  resource :follow_up, only: :create

  resources :patients, only: %i[ index new create show edit update ] do
    resources :care_plans, only: %i[ new create ]
  end

  resources :care_plans, only: %i[ show edit update ] do
    resources :check_ins, only: :create
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"
end
