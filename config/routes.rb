# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  devise_for :admins

  root           to: 'home#index'
  post 'issue',  to: 'home#issue'
  post 'return', to: 'home#return'

  resources :devices do
    member do
      get 'barcode'
    end
  end

  resources :issuers do
    member do
      get 'barcode'
    end
  end

  resources :settings, except: :show
end
