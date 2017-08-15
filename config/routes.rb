Rails.application.routes.draw do

  resources :scrape_fails, only: [:index, :show, :update]

  devise_for :admins

  authenticated :admin do
    root to:'scrape_fails#index'
  end

  root to: 'welcome#index'

end
