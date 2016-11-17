Rails.application.routes.draw do
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