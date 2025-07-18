Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  scope "(:locale)", locale: /#{I18n.available_locales.join('|')}/ do
    root "pages#home"
    get "year_select",        to: "year_select#show",    as: :year_select
    patch "year_select", to: "year_select#update"
    get "email_address/edit", to: "email_address#edit", as: "edit_email_address"
    patch "email_address", to: "email_address#update"
  end
end
