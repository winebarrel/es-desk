Rails.application.routes.draw do
  resources :resultsets, except: :new
  resources :queries
  resources :indices do
    get 'rename', to: 'indices#rename'
    post 'update_name', to: 'indices#update_name'
  end
  resources :datasets do
    get 'import', to: 'datasets#import'
    get 'download', to: 'datasets#download'
    get 'copy', to: 'datasets#copy'
  end
  get 'visitors/query', to: 'visitors#query'
  root to: 'visitors#index'
end
