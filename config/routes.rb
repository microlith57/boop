# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  devise_for :admins

  root to: 'home#index'

  get  'issuer_info', to: 'home#issuer_info'
  post 'issue',  to: 'home#issue'
  post 'return', to: 'home#return'

  resources :barcodes, only: %i[index show]

  resources :devices do
    get 'barcode', on: :member

    post 'upload', on: :collection
  end

  resources :issuers do
    get 'barcode', on: :member

    post 'upload', on: :collection
  end
end
