Rails.application.routes.draw do
  root to: 'homepage#index'

  post '/' => 'homepage#index'
end
