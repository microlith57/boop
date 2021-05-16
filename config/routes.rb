# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  devise_for :admins

  root to: 'home#index'
  get 'borrower_info', to: 'home#borrower_info'

  resources :barcodes, only: %i[index show]

  resources :devices do
    get 'barcode', on: :member
    get 'loans',   on: :member, to: 'loans#index_device'

    post 'upload', on: :collection
  end

  resources :groups, except: %i[new edit]

  resources :borrowers do
    get 'barcode', on: :member
    get 'loans',   on: :member, to: 'loans#index_borrower'

    post 'upload', on: :collection
  end

  resources :loans, only: %i[index create] do
    post 'return', on: :collection
  end
end
