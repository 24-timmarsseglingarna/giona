Rails.application.routes.draw do
  # resources :logs # Don't manage logs from web ui at the moment.

  resources :agreements do
    collection do
      get 'latest'
    end
    member do
    end
  end

  resources :agreements
  resources :default_starts
  resources :legs
  resources :terrains
  resources :points
  resources :organizers

  resources :handicaps
  resources :srs_keelboats, controller: 'handicaps', type: 'SrsKeelboats'
  resources :srs_multihulls, controller: 'handicaps', type: 'SrsMultihulls'
  resources :srs_dingies, controller: 'handicaps', type: 'SrsDingies'
  resources :srs_certificates, controller: 'handicaps', type: 'SrsCertificates'
  resources :sxk_certificates, controller: 'handicaps', type: 'SxkCertificates'

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :people,        only: [:index, :show]
      resources :boats,         only: [:index, :show]
      resources :teams,         only: [:index, :show]
      resources :logs,          only: [:index, :show, :create, :update]
      resources :races,         only: [:index, :show]
      resources :regattas,      only: [:index, :show]
      resources :organizers,      only: [:index, :show]
    end
  end

  resources :boats
  post 'teams/set_skipper'
  post 'teams/add_seaman'
  post 'teams/remove_seaman'
  post 'teams/remove_handicap'
  post 'teams/set_handicap_type'
  post 'teams/remove_boat'
  post 'teams/set_boat'
  post 'teams/submit'
  post 'teams/set_handicap'
  post 'teams/draft'
  post 'teams/approve'
  post 'teams/review'
  get 'teams/edit_boat'
  get 'teams/welcome'
  get 'teams/crew'

  resources :teams do
  	collection do
    end
    member do
      get 'edit_handicap'
      patch 'update_handicap'
    end
  end

  resources :regattas do
  	collection do
    end
    member do
      get 'start_list'
      get 'email_list'
      get 'result'
    end
  end
  post 'regattas/archive'


  resources :teams
  resources :logs
  resources :team_logs, controller: 'logs', type: 'TeamLogs'
  resources :admin_logs, controller: 'logs', type: 'AdminLogs'

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
      get 'agreement'
      post 'consent'
    end
  end


  root to: "teams#welcome"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
