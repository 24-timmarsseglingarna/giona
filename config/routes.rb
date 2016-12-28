Rails.application.routes.draw do

  resources :teams
  resources :races
  resources :regattas
  root to: "people#index"

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


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end