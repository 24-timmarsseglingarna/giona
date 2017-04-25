Rails.application.routes.draw do

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :people,        only: [:index, :show]
      resources :boats,         only: [:index, :show]
      resources :boat_classes,  only: [:index, :show]
      resources :teams,         only: [:index, :show]
      resources :races,         only: [:index, :show]
      resources :regattas,      only: [:index, :show]
    end
  end

  resources :boats
  resources :teams
  post 'teams/set_skipper'
  get 'teams/add_seaman'
  post 'teams/remove_seaman'

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