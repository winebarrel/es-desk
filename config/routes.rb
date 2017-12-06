Rails.application.routes.draw do
  resources :resultsets, except: :new
  resources :queries
  resources :indices
  resources :datasets
  post 'datasets/import', to: 'datasets#import'
  post 'datasets/download', to: 'datasets#download'
  post 'datasets/copy', to: 'datasets#copy'
  get 'visitors/query', to: 'visitors#query'
  root to: 'visitors#index'
end
