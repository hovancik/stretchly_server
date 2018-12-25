Rails.application.routes.draw do
  namespace :app do
    root 'home#show'
    get '/auth/:provider/callback', to: 'sessions#create'
    resources :sessions, only: [:destroy]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
