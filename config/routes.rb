Rails.application.routes.draw do

  devise_for :admins
  get :dashboards, to: 'welcome#index'
  root to: 'welcome#index'

end
