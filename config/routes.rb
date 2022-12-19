Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  # post '/users', to: 'users#create'
  # get '/users/:id', to: 'users#show'
  # get 'validation_codes/create'
  get '/api/v1/getFirstItem', to: 'api/v1/items#getFirstItem' 
  namespace :api do
    namespace :v1 do
      resource :validation_codes, only: [:create] # 可使用 curl -X POST http://127.0.0.1:3000/api/v1/validation_codes 来调用
      resource :session, only: [:create, :destroy]
      resource :me, only: [:show]
      resource :items #create、destroy、show、update
      resource :tags
    end  
  end  
end
