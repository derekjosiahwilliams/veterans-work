Rails.application.routes.draw do
  devise_for :companies, :controllers => { registrations: 'companies/registrations'}
  get '/companies' => 'companies#index'
  get '/companies/:id' => 'companies#show'

  resources :customer_requests
end
