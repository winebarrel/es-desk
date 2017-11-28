Rails.application.routes.draw do
  resources :resultsets, only: [:index, :show, :create]
  resources :queries
  resources :indices
  resources :datasets
  post 'datasets/import', to: 'datasets#import'
  get 'visitors/query', to: 'visitors#query'
  root to: 'visitors#index'
end
