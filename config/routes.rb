Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  # post '/users', to: 'users#create'
  # get '/users/:id', to: 'users#show'

  namespace :api do
    namespace :v1 do
      resource :validation_codes, only: [:create]
      resource :session, only: [:create, :destroy]
      resource :me, only: [:show]
      resource :items #create、destroy、show、index
      resource :tags
    end  
  end  
end
