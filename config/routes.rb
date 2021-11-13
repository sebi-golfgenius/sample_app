Rails.application.routes.draw do

  root 'static_pages#home'

  get '/home', to: 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  
  get '/signup', to: 'users#new', as: 'signup'
  get 'users/show', to: 'users#show'
  get 'users/new', to: 'users#new'

  resources :users
end
