Rails.application.routes.draw do
  resources :resultsets, only: [:index, :show, :create, :destroy]
  resources :queries
  resources :indices
  resources :datasets
  post 'datasets/import', to: 'datasets#import'
  post 'datasets/download', to: 'datasets#download'
  get 'visitors/query', to: 'visitors#query'
  root to: 'visitors#index'
end
