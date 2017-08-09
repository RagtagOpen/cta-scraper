Rails.application.routes.draw do

  resources :scrape_fails, only: [:index, :show, :update]

  devise_for :admins
  root to: 'welcome#index'

end
