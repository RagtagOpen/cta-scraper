Rails.application.routes.draw do

  devise_for :admins
  get :dashboards, to: 'dashboard#index'
  root to: 'welcome#index'

end
