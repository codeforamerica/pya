Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  get "/500", to: "public_pages#internal_server_error"
  get "/422", to: "public_pages#internal_server_error"
  get "/404", to: "public_pages#page_not_found"

  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    root "pages#home"
    get "year_select", to: "year_select#show", as: :year_select
    patch "year_select", to: "year_select#update"
    get "email_address/show", to: "email_address#edit", as: "edit_email_address"
    patch "email_address", to: "email_address#update"
    get "knock_out", to: "pages#knock_out"
    get "phone_number/show", to: "phone_number#edit", as: "edit_phone_number"
    patch "phone_number", to: "phone_number#update"
    get "contact_preference/show", to: "contact_preference#show"
    patch "contact_preference", to: "contact_preference#update"
    get "verification_code/edit", to: "verification_code#edit", as: "edit_verification_code"
    patch "verification_code", to: "verification_code#update"

    devise_for :state_file_archived_intakes
  end
end
