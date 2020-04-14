Rails.application.routes.draw do
  root 'home#show'
  namespace :app do
    root 'home#show'
    get '/auth/:provider/callback', to: 'sessions#create'
    resources :sessions, only: [:destroy]
    namespace :v1 do
      root 'home#show'
      get '/auth/:provider/callback', to: 'sessions#create'
      resources :sessions, only: [:destroy]
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
