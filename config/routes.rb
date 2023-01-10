Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get '/', to: 'home#index'

  namespace :api do
    namespace :v1 do 
      resources :validation_codes, only: [:create]
      resource :session, only: [:create, :destroy]
      resource :me, only: [:show]
      resources :items do
        collection do
          get :summary # 添加/api/v1/items/summary 图表查询接口
          get :overview # 添加/api/v1/items/overview 账单概览接口
        end
      end
      resources :tags
    end
  end

end