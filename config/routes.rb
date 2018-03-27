Rails.application.routes.draw do
  resources :default_starts
  resources :legs
  resources :terrains
  resources :points
  resources :organizers
  
  resources :handicaps
  resources :srs_keelboats, controller: 'handicaps', type: 'SrsKeelboats'
  resources :srs_multihulls, controller: 'handicaps', type: 'SrsMultihulls'
  resources :srs_dingies, controller: 'handicaps', type: 'SrsDingies'
  resources :legacy_boat_types, controller: 'handicaps', type: 'LegacyBoatTypes'
  resources :srs_certificates, controller: 'handicaps', type: 'SrsCertificates'
  resources :sxk_certificates, controller: 'handicaps', type: 'SxkCertificates'

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :people,        only: [:index, :show]
      resources :boats,         only: [:index, :show]
      resources :teams,         only: [:index, :show]
      resources :races,         only: [:index, :show]
      resources :regattas,      only: [:index, :show]
      resources :organizers,      only: [:index, :show]
    end
  end

  resources :boats
  post 'teams/set_skipper'
  get 'teams/add_seaman'
  post 'teams/remove_seaman'
  post 'teams/remove_handicap'
  post 'teams/set_handicap_type'
  post 'teams/remove_boat'
  post 'teams/set_boat'
  get 'teams/edit_boat'
  get 'teams/welcome'

  resources :teams

  resources :races
  resources :regattas

  devise_for :users

  resources :users do
    collection do
      get 'inactive'
    end
    member do
      get 'recover'
    end
  end

  resources :people do
  	collection do
      get 'inactive'
    end
    member do
      get 'recover'
    end
  end

  root to: "regattas#index"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
