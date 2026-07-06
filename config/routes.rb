require "sidekiq/web"

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  authenticate :user do
    mount Sidekiq::Web => "/sidekiq"
  end

  root "home#index"
  devise_for :users, controllers: { registrations: "users/registrations" }
  get "dashboard", to: "dashboard#index"
  get "members", to: "members#index"

  resource :settings, only: [ :show, :update ], controller: "settings"
  delete "settings/profile_picture", to: "settings#destroy_profile_picture", as: :settings_profile_picture

  resources :invitations, only: [ :new, :create ]
  get  "invitations/:token/accept",   to: "invitation_acceptances#show",    as: :accept_invitation
  post "invitations/:token/accept",   to: "invitation_acceptances#create"
  post "invitations/:token/decline",  to: "invitation_acceptances#decline",  as: :decline_invitation
end
